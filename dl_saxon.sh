echo "downloading saxon"
wget -O saxon.zip https://github.com/Saxonica/Saxon-HE/raw/refs/heads/main/12/Java/SaxonHE12-5J.zip && \
unzip saxon.zip -d saxon && \
rm -f saxon.zip