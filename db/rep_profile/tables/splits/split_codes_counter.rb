# Data table definition file.
# dbo.splitCodesCounter
# Contains templates for split codes automatic generation.

table :splitCodesCounter do
  col :prefix, len: 10, required: true
  col :maxDigitalLength, type: :byte, required: true
  col :setLeading0, type: :bool, required: true, default: true
  col :lastCandidate, type: :int, required: true
end
