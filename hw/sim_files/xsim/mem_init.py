
lines = int((2**34)/64) # 64 bytes per line
lines = 1024 # 64 bytes per line

with open('memory.mem', 'w') as f:
    for i in range(lines):
        line = '0' * 128
        f.write(line)
        f.write('\n')

