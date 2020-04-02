import xxtea
import os

fileName = "TransmitLogin"

#   open from .luac
readFile = open("./" + fileName + ".luac", "rb+")
content = readFile.read()

content = "python"

#   decrypt
#sign = "bianfengqipai"
key = "03f0fdcbf5215b45fc790aaf2b965238"
data = xxtea.encrypt(content, key)

data = xxtea.decrypt(data, key)
#   write to .lua
writeFile = open("./" + fileName + ".lua", "w")
writeFile.write(data)
writeFile.close()
#\xeeo`G{M\x1b\x08\x8e\x1b\x87