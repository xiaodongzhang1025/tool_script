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

def docx_pdf(docx_path, pdf_path):
    #word_app = Dispatch("Word.Application")
    word_app = gencache.EnsureDispatch("Word.Application")
    try:
        doc = word_app.Documents.Open(docx_path, ReadOnly=1)
        doc.ExportAsFixedFormat(pdf_path, constants.wdExportFormatPDF,\
                                Item=constants.wdExportDocumentWithMarkup,\
                                CreateBookmarks=constants.wdExportCreateHeadingBookmarks)
    except Exception, err:
        print err
    finally:
        word_app.Quit(constants.wdDoNotSaveChanges)
        print '===>', pdf_path
    

if "__main__" == __name__:
    if len(sys.argv) < 2:
        print 'Para error.'
        print 'Usage: dir_path'
        sys.exit(-1)
    print '\n------------------------------The Start-----------------------------'
    start_time = time.clock()
    
    target_path = sys.argv[1]
    target_path = os.path.abspath(target_path)
    for root, dirs, files in os.walk(target_path):
        for file in files:
            file_path = os.path.join(root, file)
            tmp_path, ext = os.path.splitext(file_path)
            if ext == '.docx' or ext == '.doc':
                print '\n-----------------------', file_path
                docx_pdf(file_path, tmp_path + '.pdf')

    print '\n------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)
    
