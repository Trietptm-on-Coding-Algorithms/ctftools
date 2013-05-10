# Basically create a gdbinit file that replaces the
# given program with shellcode in-memory, which allows
# us to take control of a running process that we may
# not have write access to

if(ARGV.length != 3)
  $stderr.puts("Usage: create_hijack_gdbint.rb <shellcode.bin> <program> <address to make the change>")
  exit(1)
end

shellcode = ARGV[0]
program   = ARGV[1]
address   = ARGV[2]

File.open(ARGV, "r") do |f|
  puts("set disassembly-flavor intel")
  puts("set confirm off")
  puts("")
  puts("file \"#{program}\"")
  puts("break #{address}")
  puts("run")
  puts("")

  data = f.read()
  offset = 0
  data.each_byte do |b|
    puts("set {char}#{address}+#{offset}=0x%02x" % [b])
    offset += 1
  end

  puts("cont")
end

