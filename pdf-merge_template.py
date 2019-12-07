#coding:utf-8
__author__ = 'zhangxiaodong'
import sys
import os
import codecs
import time
import shutil
from win32com.client import Dispatch, constants, gencache
import win32print
import win32api
from PyPDF2 import PdfFileWriter,PdfFileReader

def merge_pdf_watermark(src_pdf_path, watermark_pdf_path, dst_pdf_path):
    try:
        watermark = PdfFileReader(watermark_pdf_path)
        watermark_page = watermark.getPage(0)
        src_pdf = PdfFileReader(src_pdf_path, strict = False)
        pdf_writer = PdfFileWriter()
        for page_index in range(src_pdf.getNumPages()):
            pdf_page = src_pdf.getPage(page_index)
            pdf_page.mergePage(watermark_page)
            pdf_writer.addPage(pdf_page)
        pdfOutputFile = open(dst_pdf_path, 'wb')
        #pdf_writer.encrypt('qg2101')#设置pdf密码
        pdf_writer.write(pdfOutputFile)
        pdfOutputFile.close()
    except Exception, err:
        print err
    finally:
        print '===>', dst_pdf_path
        
if "__main__" == __name__:
    if len(sys.argv) < 3:
        print 'Para error.'
        print 'Usage: dir_path watermark_pdf_path'
        sys.exit(-1)
    print '\n------------------------------The Start-----------------------------'
    start_time = time.clock()
    
    target_path = sys.argv[1]
    target_path = os.path.abspath(target_path)
    watermark_pdf_path = sys.argv[2]
    watermark_pdf_path = os.path.abspath(watermark_pdf_path)
    print target_path, watermark_pdf_path
    for root, dirs, files in os.walk(target_path):
        for file in files:
            file_path = os.path.join(root, file)
            tmp_path, ext = os.path.splitext(file_path)
            if ext == '.pdf':
                if tmp_path.endswith('_QgWatermark'):
                    continue
                print '\n-----------------------', file_path
                merge_pdf_watermark(file_path, watermark_pdf_path, tmp_path + '_QgWatermark' + ext)

    print '\n------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)
    
