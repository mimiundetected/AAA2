#!/bin/bash
# Imei Check Valid
cek_panjang=$(echo $1 | wc -L)
if [[ "${cek_panjang}" == '15' ]]; then
    imei_cek=$(echo $1 | fold -w 14 | head -1)
fi
luhn_checksum() {
    sequence="$1"
    sequence="${sequence//[^0-9]}" # numbers only plz
    checksum=0
    table=(0 2 4 6 8 1 3 5 7 9)
    i=${#sequence}
    if [ $(($i % 2)) -ne 0 ]; then
        sequence="0$sequence"
        ((++i))
    fi
    while [ $i -ne 0 ]; do
        checksum="$(($checksum + ${sequence:$((i - 1)):1}))"
        checksum="$(($checksum + ${table[${sequence:$((i - 2)):1}]}))"
        i=$((i - 2))
    done
    checksum="$(($checksum % 10))" # mod 10 the sum to get single digit checksum
    echo "$checksum"
}

# Returns Luhn check digit for supplied sequence
luhn_checkdigit() {
    check_digit=$(luhn_checksum "${1}0")
    if [ $check_digit -ne 0 ]; then
        check_digit=$((10 - $check_digit))
    fi
    echo "$check_digit"
}

# Tests if last digit is the correct Luhn check digit for the sequence
# Returns true if valid, false if not
luhn_test() {
    if [ "$(luhn_checksum $1)" == "0" ]; then
        return 0
    else
        return 1
    fi
}
for (( i = 0; i < 10; i++ )); do
    sample_imei="${imei_cek}${i}"
    if luhn_test "$sample_imei"; then
        echo "${sample_imei} valid IMEI"
    fi
done
