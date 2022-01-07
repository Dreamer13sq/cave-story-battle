import os
import sys
import string
import pyperclip

VARCHAR = string.ascii_letters + '_0123456789';

def CorrectStatements(path):
    argv = sys.argv
    argc = len(sys.argv)
    
    if argc <= 1:
        print('> No file path given')
        return
    
    rootpath = argv[1].replace('\\', '/');
    rootpath = rootpath[:rootpath.rfind('/')+1]
    print(rootpath)
    
    
    
    f = open(fpath, 'r')
    if not f:
        print('> Error opening file "%s"' % fpath)
        return
    
    
    
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

def CorrectLoop(path):
    pathlist = os.listdir(path)
    
    for p in pathlist:
        fullpath = path+'/'+p
        
        # Dir
        if not os.path.isfile(fullpath):
            CorrectStatements(fullpath)
        # File
        else:
            f = open(fullpath, 'r')
            
            if f:
                for l in f:
                    if 'if' in l:
                        print(l)
                
                f.close()

main();
