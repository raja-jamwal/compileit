#
# Compileit : tiny bash script to compile files into executables
#
#	Copyright (C) 2011  Raja Jamwal <www.experiblog.co.cc> 
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
cd $1
mkdir -p objects
## create object files
for file in $( ls -l | grep ^- | awk '{print $8}')
do
echo "Compiling $file..."
ld -r -b binary $file -o objects/$file.o
done
cd objects

for file in $( ls -l | grep ^- | awk '{print $8}')
do
name=`objdump -x $file | grep -o "_binary_[^ ]*_start"`
echo "$name" >> ../../tables
done

IFS=$'\n'

for line in $(cat ../../tables)
do
echo "extern char $line[];extern int `echo $line | sed 's/start/size/'`;" >> ../../var
done

echo -e "#include <iostream>\n#include <fstream>\n
#include <stdlib.h>\nusing namespace std;\n" >> ../../main.c

cat ../../var >> ../../main.c
echo -e "int extract(char * szData, char * filename, unsigned int size){\n
cout << \"extracting \" << filename << endl;\n
ofstream fout(filename, ios::out | ios::binary);\n
fout.write(szData, size);\n
fout.close();\n
}" >> ../../main.c 

echo "int main()" >> ../../main.c
echo "{" >> ../../main.c
echo "cout << \"<www.experiblog.co.cc> (C) Raja\" << endl;" >> ../../main.c

for line in $(cat ../../tables)
do
echo "extract($line, \"`echo $line | sed 's/start//' | sed 's/_binary//'`\", (int) &`echo $line | sed 's/start/size/'`);" >> ../../main.c
done
echo "return 0;" >> ../../main.c
echo "}" >> ../../main.c

g++ ../../main.c -o ../../main $( ls -l | grep ^- | awk '{print $8}')

