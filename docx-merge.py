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

    
def merge_docx(src1_docx_path, src2_docx_path, dst_docx_path):
    #word_app = Dispatch("Word.Application")
    word_app = gencache.EnsureDispatch("Word.Application")
    try:
        output = word_app.Documents.Add()
        output.Application.Selection.Range.InsertFile(src2_docx_path)
        output.Application.Selection.Range.InsertFile(src1_docx_path)
        doc = output.Range(output.Content.Start, output.Content.End)
        output.SaveAs(dst_docx_path)
        output.Close()
    except Exception, err:
        print err
    finally:
        word_app.Quit(constants.wdDoNotSaveChanges)
        print '===>', dst_docx_path

if "__main__" == __name__:
    if len(sys.argv) < 3:
        print 'Para error.'
        print 'Usage: dir_path template_docx_path'
        sys.exit(-1)
    print '\n------------------------------The Start-----------------------------'
    start_time = time.clock()
    
    target_path = sys.argv[1]
    target_path = os.path.abspath(target_path)
    template_path = sys.argv[2]
    template_path = os.path.abspath(template_path)
    print target_path, template_path
    for root, dirs, files in os.walk(target_path):
        for file in files:
            file_path = os.path.join(root, file)
            tmp_path, ext = os.path.splitext(file_path)
            if ext == '.docx' or ext == '.doc':
                if tmp_path.endswith('_QgCover'):
                    continue
                print '\n-----------------------', file_path
                merge_docx(template_path, file_path, tmp_path + '_QgCover' + ext)

    print '\n------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)
    
