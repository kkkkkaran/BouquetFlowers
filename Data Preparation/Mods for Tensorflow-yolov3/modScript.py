import csv

def flowerId(row_label):
    if row_label == 'Rose':
        return '0'
    elif row_label == 'Carnation':
        return '1'
    elif row_label == 'Daffodil':
        return '2'
    elif row_label == 'Sunflower':
        return '3'
    elif row_label == 'Tulip':
        return '4'
    elif row_label == 'Orchid':
        return '5'
    elif row_label == 'Lavender':    
        return '6'
    elif row_label == 'Lily':    
        return '7'
    elif row_label == 'Iris':    
        return '8'    
    else:
        None
lines = []
count = 0
with open('flowersAll_test.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    dummy = str("346168.jpg")
    print(dummy)
    line = ''
    for row in readCSV:
        count = count + 1

        if count != 1:
            try:
                print(row[0])

                if(dummy == str(row[0])):
                    if line is None:
                        line = ""
                    else:
                        flowerid=flowerId(row[3])
                        print(flowerid)
                        line = line + "," + row[4] + "," + row[5] + "," + row[6] + "," + row[7] + "," + flowerid
                        print("we are here")
                        print(line)
                else:
                    endline = str(dummy)+line
                    lines.append(endline)
                    line = ''
                    dummy = row[0]
                    if line is None:
                        line = ""
                    else:
                        flowerid=flowerId(row[3])
                        print(flowerid)
                        line = line+ ","+row[4]+","+row[5]+","+row[6]+","+row[7]+","+flowerid
            except:
                pass
    with open('your_file.txt', 'w') as f:
        for item in lines:
            f.write("%s\n" % item)
