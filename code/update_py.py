import sys

with open("extreme_weather.py","r") as infile:
    lines=infile.readlines()
    for i, line in enumerate(lines):
        line=line.strip()
        if "S3_BUCKET" in (bucket := line.split("=")[0]):
            print("found it!")
            print(bucket)
            lines[i] = f"S3_BUCKET = \"{sys.argv[1]}\"\n"
            print(lines[i])
            break

with open("extreme_weather.py","w") as outfile:
    outfile.write("".join(lines))