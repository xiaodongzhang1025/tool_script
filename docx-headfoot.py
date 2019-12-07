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

    
def headfoot_docx(src_docx_path, template_docx_path, dst_docx_path):
    #word_app = Dispatch("Word.Application")
    word_app = gencache.EnsureDispatch("Word.Application")
    try:
        section0_header0 = None
        section0_footer0 = None
        output = word_app.Documents.Add()
        output.Application.Selection.Range.InsertFile(src_docx_path)
        outdoc = output.Range(output.Content.Start, output.Content.End)
        for section_index, section in enumerate(outdoc.Sections):
            for header_index, header in enumerate(section.Headers):
                #print 'section [%d], header [%d]'%(section_index, header_index)
                #print header.Range.Text
                section0_header0 = header
                break
            for footer_index, footer in enumerate(section.Footers):
                #print 'section [%d], footer [%d]'%(section_index, footer_index)
                #print footer.Range.Text
                section0_footer0 = footer
                break
        ###############################################################
        template_doc = word_app.Documents.Open(template_docx_path)
        
        for section_index, section in enumerate(template_doc.Sections):
            for header_index, header in enumerate(section.Headers):
                #print 'section [%d], header [%d]'%(section_index, header_index)
                #print header.Range.Text
                template_section0_header0 = header
                break
            for footer_index, footer in enumerate(section.Footers):
                #print 'section [%d], footer [%d]'%(section_index, footer_index)
                #print footer.Range.Text
                template_section0_footer0 = footer
                break
        #print template_section0_header0.Range.Text
        #print template_section0_footer0.Range.Text
        template_section0_header0.Range.Copy()
        section0_header0.Range.Paste()
        
        template_section0_footer0.Range.Copy()
        section0_footer0.Range.Paste()
        
        template_doc.Close()
        ################################################################
        output.SaveAs(dst_docx_path)
        output.Close()
    except Exception, err:
        #print err
        print str(err).decode("string_escape")
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
                if tmp_path.endswith('_QgHeadFoot'):
                    continue
                print '\n-----------------------', file_path
                headfoot_docx(file_path, template_path, tmp_path + '_QgHeadFoot' + ext)

    print '\n------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)
    
