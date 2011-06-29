module XRay

    ScanLogEntry = Struct.new :file_name, :row, :col, :level, :code, :msg
    LEVEL_INFO = 1
    LEVEL_WARN = 2
    LEVEL_FATAL = 3

end
