import os

out = open('vga_rom.v', 'w')
# write header
out.write('module vga_rom(\n')
out.write('\tinput wire[6:0] ch,\n')
out.write('\tinput wire[9:0] pos,\n')
out.write('\toutput reg mask\n);\n')
out.write('\n\nalways @(*) begin\n')
out.write('\tcase(ch[6:0])\n')

# write rom
files = os.listdir('chars')
for f in files:
    path = './chars/' + f
    print 'Parsing ' + path
    x = open(path).read().replace('\n', '')
    out.write('\t\t%s: begin\n' % f)
    index = x.find('1') 
    if (index == -1):
        out.write('\t\t\tmask = 0;\n')
    else:
        out.write('\t\t\tcase(pos[9:0])\n')
        out.write('\t\t\t\t%d' % index)
        index += 1
        while(index < len(x)):
            index = x.find('1', index)
            if (index == -1):
                break
            out.write(', %d' % index)
            index += 1
        out.write(':\n\t\t\t\t\tmask = 1;\n')
        out.write('\t\t\t\tdefault: mask = 0;\n')
        out.write('\t\t\tendcase\n')
    out.write('\t\tend\n')

# write footer 
out.write('\t\tdefault: mask = 0;\n')
out.write('\tendcase\nend\n\nendmodule')