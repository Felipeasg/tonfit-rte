#https://stackoverflow.com/questions/926069/add-up-a-column-of-numbers-at-the-unix-shell

arm-none-eabi-size *.o

echo "Total: "
arm-none-eabi-size *.o | cut -d$'\t' -f4 | grep -P '\d' | paste -sd+ - | bc
