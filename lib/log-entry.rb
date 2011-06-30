module XRay

    ScanLogEntry = Struct.new :file_name, :row, :col, :level, :code, :msg
    class ScanLogEntry
        def to_s
            "[#{level.to_s.upcase}] [#{row},#{col}] #{code.to_s.upcase} #{msg}"
        end
    end

end
