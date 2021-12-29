import sys
import string
import pyperclip

VARCHAR = string.ascii_letters + '_0123456789';

'''
    D:\Cave-Story-Series\fighter\cave-fighter\scripts\scr_fighter_const\scr_fighter_const.gml
'''

def main():
    argv = sys.argv
    argc = len(sys.argv)
    
    if argc <= 1:
        print('> No file path given')
        return
    
    fpath = argv[1];
    enumindex = 0 if argc <= 2 else argv[2]
    
    f = open(fpath, 'r')
    if not f:
        print('> Error opening file "%s"' % fpath)
        return
    
    mode = 0
    s = ''
    names = []
    enumname = ''
    
    def NextWord(line, start=0):
        p1 = start+min([x[0] for x in enumerate(line[start:]) if x[1] in VARCHAR])
        p2 = p1+min([x[0] for x in enumerate(line[p1+1:]) if x[1] not in VARCHAR])+1
        return line[p1:p2]
    
    for l in f:
        
        if mode == 0:
            if 'enum ' in l:
                if enumindex > 0:
                    enumindex -= 1
                    continue
                mode = 1
                enumname = NextWord(l, l.find('enum ')+len('enum '));
                
        elif mode == 1:
            l = l.replace(' ', '');
            l = l.replace('\t', '');
            
            if '{' in l:
                continue
            if '//' in l:
                l = l[:l.find('//')]
            if '}' in l:
                mode = 0
                break
            
            if not [x for x in l if x in VARCHAR]:
                continue
            
            p1 = min([x[0] for x in enumerate(l) if x[1] in VARCHAR])
            p2 = p1+min([x[0] for x in enumerate(l[p1+1:]) if x[1] not in VARCHAR])+1
            l = NextWord(l);
            
            names.append(l)
    f.close()
    
    out = ''
    
    out += 'function %s_GetName(enumvalue)\n{\n' % enumname
    out += '\tswitch(enumvalue)\n'
    out += '\t{\n'
    for n in names:
        out += ('\t\tcase(%s.%s): return "%s";\n' % (enumname, n, n))
    out += '\t}\n'
    out += '\treturn "<unknown>";\n'
    out += '}\n'
    
    pyperclip.copy(out)

main();
