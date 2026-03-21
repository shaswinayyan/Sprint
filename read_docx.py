import zipfile
import xml.etree.ElementTree as ET

def read_docx(file_path):
    doc = zipfile.ZipFile(file_path)
    content = doc.read('word/document.xml')
    tree = ET.XML(content)
    
    paragraphs = []
    for paragraph in tree.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
        texts = [node.text for node in paragraph.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t') if node.text]
        if texts:
            paragraphs.append(''.join(texts))
    return '\n'.join(paragraphs)

print(read_docx('g:/IITM/Sprint/G1.Hospital Management System.docx'))
