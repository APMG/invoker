module Invoker
  class ProcessPrinter
    MAX_COLUMN_WIDTH = 40
    attr_accessor :list_response

    def initialize(list_response)
      self.list_response = list_response
    end

    def print_table
      hash_with_colors = []
      list_response.processes.each do |process|
        if process.pid
          hash_with_colors << colorize_hash(process, "green")
        else
          hash_with_colors << colorize_hash(process, "light_black")
        end
      end
      Formatador.display_compact_table(hash_with_colors)
    end

    def print_raw_text
      Formatador.display_line("[green]--------------------------------------[/]")
      list_response.processes.each do |process|
        Formatador.display_line("[bold]Process Name : #{process.process_name}[/]")
        Formatador.indent {
          Formatador.display_line("Dir : #{process.dir}")
          if process.pid
            Formatador.display_line("PID : #{process.pid}")
          else
            Formatador.display_line("PID : Not Running")
          end
          Formatador.display_line("Port : #{process.port}")
          Formatador.display_line("Command : #{process.shell_command}")
        }
        Formatador.display_line("[green]--------------------------------------[/]")
      end
    end

    private

    def colorize_hash(process, color)
      hash_with_colors = {}

      hash_with_colors['dir'] = colored_string(process.dir, color)
      hash_with_colors['pid'] = colored_string(process.pid || 'Not Running', color)
      hash_with_colors['port'] = colored_string(process.port, color)
      hash_with_colors['shell_command'] = colored_string(process.shell_command, color)
      hash_with_colors['process_name'] = colored_string(process.process_name, color)
      hash_with_colors
    end

    def colored_string(string, color)
      string = string.to_s
      if string.length > MAX_COLUMN_WIDTH
        string = "#{string[0..MAX_COLUMN_WIDTH]}.."
      end
      "[#{color}]#{string}[/]"
    end
  end
end
