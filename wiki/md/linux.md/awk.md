### Awk
--------
[Based on](https://habrahabr.ru/company/ruvds/blog/327754/)

1. ##### Format
    
            awk options program file

    By default
    
            awk '{print "Some text\n"}'

    'awk' waits data from the 'stdin' so that whenever you print a line the awk will print "Some text\n".

3. ##### Fileds
    To manipulate with fields we can use references: $0, $1, ... - the field are delimited with the 'space' by default but we can set the delimeter with the '-F' flag. Note that $0 - the whole string.

4. ##### Files 
    To pass a file 'awk' commands we can specified use 'f' flag

            awk -f $File -F : 

5. ##### Using *BEGIN* and *END*. 
    To execute a command before/after processing we can use *BEGIN/END*

            BEGIN { ... }
            { print "Hello!!!\n" }
            END {...}

6. ##### List of specific parameters:

    *FIELDWIDTHS* — разделённый пробелами список чисел,
    определяющий точную ширину каждого поля данных с учётом разделителей полей.

    *FS* — уже знакомая вам переменная, позволяющая задавать символ-разделитель полей.
    
    *RS* — переменная, которая позволяет задавать символ-разделитель записей.
    
    *OFS* — разделитель полей на выводе awk-скрипта.
    
    *ORS* — разделитель записей на выводе awk-скрипта.

    Using *FS*, *OFS*:

            awk 'BEGIN{FS=":"; OFS="-"} {print $1,$6,$7}' /etc/passwd

    Result is
            
            root-/root-...

    Using FIELDWIDTHS:
    
            $ awk 'BEGIN{FIELDWIDTHS="3 5 2 5"}{print $1,$2,$3,$4}' testfile
        
    Data:

            1235.9652147.91
            927-8.365217.27
            36257.8157492.5
    
    Result:
        
            123 5.965 21 47.91

7. ##### Built-in variables

    *ARGC* — количество аргументов командной строки.

    *ARGV* — массив с аргументами командной строки.

    *ARGIND* — индекс текущего обрабатываемого файла в массиве ARGV.

    *ENVIRON* — ассоциативный массив с переменными окружения и их значениями.

    *ERRNO* — код системной ошибки, которая может возникнуть при чтении или 
    закрытии входных файлов.

    *FILENAME* — имя входного файла с данными.

    *FNR* — номер текущей записи в файле данных.

    *IGNORECASE* — если эта переменная установлена в ненулевое значение, при обработке игнорируется регистр символов.

    *NF* — общее число полей данных в текущей записи.

    *NR* — общее число обработанных записей.


Example 8.1

        awk 'BEGIN{print ARGC,ARGV[1]}' myfile

Example 8.2

        awk '
        BEGIN{
        print ENVIRON["HOME"]
        print ENVIRON["PATH"]
        }'

8. ##### Condition operators *if-then-else*

    Example 9.1

    Data:

            10
            15
            6
            33
            45

            awk '{if ($1 > 20) print $1}' testfile

    Result:

            33
            45

    Example 9.2

            awk '{
            if ($1 > 20)
            {
            x = $1 * 2
            print x
            }
            }' testfile

    Example 9.3

            awk '{
            if ($1 > 20)
            {
            x = $1 * 2
            print x
            } else
            {
            x = $1 / 2
            print x
            }}' testfile

9. ##### Loop *while*

    Example 10.1

            awk '{
            total = 0
            i = 1
            while (i < 4)
            {
            total += $i
            i++
            }
            avg = total / 3
            print "Average:",avg
            }' testfile

    Example 10.2 Using *continue, break*
    
            awk '{
            total = 0
            i = 1
            while (i < 4)
            {
            total += $i
            if (i == 2)
            break
            i++
            }
            avg = total / 2
            print "The average of the first two elements is:",avg
            }' testfile

10. ##### Loop *for*

    Example 11.1

            awk '{
            total = 0
            for (i = 1; i < 4; i++)
            {
            total += $i
            }
            avg = total / 3
            print "Average:",avg
            }' testfile

11. ##### printf

    Modifiers
    *c* — воспринимает переданное ему число как код ASCII-символа и выводит этот символ.

    *d* — выводит десятичное целое число.

    *i* — то же самое, что и d.

    *e* — выводит число в экспоненциальной форме.

    *f* — выводит число с плавающей запятой.

    *g* — выводит число либо в экспоненциальной записи, либо в формате с плавающей запятой, в зависимости от того, как получается короче.

    *o* — выводит восьмеричное представление числа.

    *s* — выводит текстовую строку.

    Example 12.1

            awk 'BEGIN{
            x = 100 * 100
            printf "The result is: %e\n", x
            }'

12. ##### Mathematic functions

    *cos(x)* — косинус x (x выражено в радианах).

    *sin(x)* — синус x.

    *exp(x)* — экспоненциальная функция.

    *int(x)* — возвращает целую часть аргумента.

    *log(x)* — натуральный логарифм.

    *rand()* — возвращает случайное число с плавающей запятой в диапазоне 0 — 1
    
    *sqrt(x)* — квадратный корень из x.

    Example 13.1

            awk 'BEGIN{x=exp(5); print x}'

13. ##### String Functions

    Example 14.1
    
            awk 'BEGIN{x = "likegeeks"; print toupper(x)}'

>[!Note] @see https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html#String-Functions

14. ##### User-defined functions

    Example 15.1

            awk '
            function myprint()
            {
            printf "The user %s has home path at %s\n", $1,$6
            }
            BEGIN{FS=":"}
            {
            myprint()
            }' /etc/passwd

15. ##### Diffs

    Example 15.1

            # вывести второе поле только если первое > 0
            awk '$1 > 0 {print $2}' file 
    
    Example 15.2            

            # обработать строки, начиная с той у которой $1>0 и до первой пустой строки
            awk '$1 > 0, length($0) == 0 {…}' file 

    Example 15.3

            # обработать строки соответствующие регекспу
            awk '/re/ {…}' file 

16. ##### [Gnu docs](https://www.gnu.org/software/gawk/manual/html_node/index.html)

17. ##### Use bash variables:

    Example 17.1

            variable="line one\nline two"
            awk -v var="$variable" 'BEGIN {print var}'

    Output:

            line one
            line two

    Example 17.2

            variable="line one\nline two"
            awk 'BEGIN {print "'"$variable"'"}'

    Output:

            line one
            line two

18. ##### Regexp

    Example 18.1
            
            awk '/foo/ { print $2 }' BBS-list

19. ##### Return a result from awk:
    
    Example 19.1 Use arrays:
 
            arr=( $(awk 'BEGIN{ r=10; q=20; printf "%04.0f %05.0f\n",r,q }') )

    Example 19.2 Use read:
 
            read rr qq <<<$(awk 'BEGIN{ r=10; q=20; rr = sprintf("%04.0f", r); qq = sprintf("%05.0f",q); print rr,qq}')

20. ##### Awk with *ps*:

    Example 21.1 Summ RSS, VSZ in ps

            ps -o pid,user,comm,rss,vsz,stat -ax | awk 'BEGIN{N>1;sum_rss=0;sum_vsz}{$4=int($4/1024);$5=int($5/1024);sum_rss+=$4;sum_vsz+=$5;print$0;}END{printf(
            "SUMM RSS: %d MB\nVSZ: %d MB\n",sum_rss,sum_vsz);}' | less 
 
    > [!Note] Take into account:
    > - to print all fileds we can use print$0; or just print;
    > - we can change field values: $5=int($5/1024)
    > - start print from 2nd RS: N>1 
    > 
    > [More here](https://catonmat.net/awk-one-liners-explained-part-three)

