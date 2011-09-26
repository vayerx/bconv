#!/usr/bin/env ruby
#############################################################################
#    Yet Another ImageMagic Frontend                                        #
#    (C) 2010-2011, Vasiliy Yeremeyev <vayerx@gmail.com>                    #
#                                                                           #
#    This program is free software: you can redistribute it and/or modify   #
#    it under the terms of the GNU General Public License as published by   #
#    the Free Software Foundation, either version 3 of the License, or      #
#    (at your option) any later version.                                    #
#                                                                           #
#    This program is distributed in the hope that it will be useful,        #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
#    GNU General Public License for more details.                           #
#                                                                           #
#    You should have received a copy of the GNU General Public License      #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.  #
#############################################################################

# TODO use 'rmagic' interface instead of Kernel.system


require 'enumerator'

def number_of_processors
    raise "Can't determine 'number_of_processors' for '#{RUBY_PLATFORM}'" unless RUBY_PLATFORM =~ /linux/
    %x[cat /proc/cpuinfo | grep processor | wc -l].to_i
end

class Converter
    def initialize
        @source_files = []
        @launcher_thread = nil
        @semaphore = Mutex.new
        @jobs_slots = (number_of_processors * 1.25 + 1).to_i rescue 1
        @jobs_slots = 1 if @jobs_slots < 1
    end

    # Asynchronously get directory listing
    def preload_dir(dir, &block)
        @counting_thread.terminate if @counting_thread
        @counting_thread = Thread.new {
            list_directory(dir)
            block.call(@source_files.size) if block_given?
        }
    end

    # Process directory
    def process(src_dir, dest_dir, size, ratio, &progress)
        @launcher_thread.join if @launcher_thread   # supposed to be quick enough
        @launcher_thread = Thread.new {
            # get directory listing
            if @counting_thread
                @counting_thread.join
                @counting_thread = nil
            else
                list_directory(src_dir)
            end

            unless @source_files.empty?
                pulse_step = 1 / @source_files.size.to_f
                @jobs=[]
                @source_files.each_slice(((@source_files.size + @jobs_slots - 1) / @jobs_slots).to_i)  do |files|
                    @jobs << Thread.new do
                        process_directory(src_dir, dest_dir, files, size, ratio, pulse_step, &progress)
                    end
                end
            else
                progress.call(nil, nil, true)
            end
        }
    end

    # Terminate all running threads
    def stop
        @launcher_thread.terminate if @launcher_thread
        @jobs.each { |thread| thread.terminate } if @jobs
        @launcher_thread, @jobs = nil, nil
    end

    private

    # Convert files
    def process_directory(src_dir, dest_dir, source_files, size, ratio, pulse_step, &progress)
        # rename files if destination is a source directory
        file_rename =
            if src_dir == dest_dir
                Proc.new { |file| file.gsub(/(.*)(\.jpe?g)$/i, "\\1_#{size}\\2") }
            else
                Proc.new { |file| file }
            end

        # process files
        size_opt = size && size.length != 0 ? "-resize #{size}" : ""
        source_files.each do |file|
            src_file = "#{src_dir}/#{file}".gsub(/([\s'()"])/, '\\\\\1')
            dest_file = "#{dest_dir}/#{file_rename[file]}".gsub(/([\s'()"])/, '\\\\\1')
            if src_file != dest_file
                progress.call(file, nil, false)
                system("convert -quality #{ratio} #{size_opt} #{src_file} #{dest_file}")
            else
                progress.call('SKIPPING ' + file, nil, false)
            end
            progress.call(nil, pulse_step, false)
        end
    ensure
        @semaphore.synchronize { progress.call(nil, nil, true) if (@amount_of_jobs -= 1) == 0 }
    end

    # Find JPEG files in a directory
    def list_directory(dir)
        @source_files = Dir.entries(dir).find_all { |file| /.*jpe?g$/i =~ file }
    end
end
