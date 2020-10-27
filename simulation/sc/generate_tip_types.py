with open('TipTypes.txt', 'w') as text_file:

    for i in range(1,101):
        if i <=50:
            text_file.write(str(i) + '\t' + str(0) + '\n')
        else:
            text_file.write(str(i) + '\t' + str(1) + '\n')
