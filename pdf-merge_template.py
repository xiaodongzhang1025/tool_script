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
reload(sys)
sys.setdefaultencoding('utf8')

def analyze_outline(pdf_reader, outline_list):
    for outline in outline_list:
        if isinstance (outline, list):
            analyze_outline(pdf_reader, outline)
        else:
            print outline
            #print outline['/Title'], pdf_reader.getDestinationPageNumber(outline)
    
def write_outline(pdf_reader, pdf_writer, outline_list, parent):
    bookmark_node = None
    for outline in outline_list:
        if isinstance (outline, list):
            write_outline(pdf_reader, pdf_writer, outline, bookmark_node)
        else:
            #print outline
            title = outline['/Title']
            page_num = pdf_reader.getDestinationPageNumber(outline)
            '''
                /Fit	No additional arguments
                /XYZ	[left] [top] [zoomFactor]
                /FitH	[top]
                /FitV	[left]
                /FitR	[left] [bottom] [right] [top]
                /FitB	No additional arguments
                /FitBH	[top]
                /FitBV	[left]
            '''
            
            ############################# !!!!! below page_num+1 is for the cover page ####################
            fit_type = outline['/Type']
            if fit_type == '/Fit' or fit_type == '/FitB':
                bookmark_node = pdf_writer.addBookmark(title, page_num + 1, parent)
                print fit_type
            elif fit_type == '/XYZ':
                left = outline['/Left'] if outline['/Left'] != None else 0
                top = outline['/Top'] if outline['/Top'] != None else 0
                zoom = outline['/Zoom'] if outline['/Zoom'] != None else 0
                #print fit_type, left, top, zoom
                bookmark_node = pdf_writer.addBookmark(title, page_num + 1, parent, None, False, False, fit_type, left, top, zoom)
            elif fit_type == '/FitR':
                left = outline['/Left'] if outline['/Left'] != None else 0
                bottom = outline['/Bottom'] if outline['/Bottom'] != None else 0
                right = outline['/Right'] if outline['/Right'] != None else 0
                top = outline['/Top'] if outline['/Top'] != None else 0
                #print fit_type, left, bottom, right, top
                bookmark_node = pdf_writer.addBookmark(title, page_num + 1, parent, None, False, False, fit_type, left, bottom, right, top)
            elif fit_type == '/FitH' or '/FitBH':
                top = outline['/Top'] if outline['/Top'] != None else 0
                #print fit_type, top
                bookmark_node = pdf_writer.addBookmark(title, page_num + 1, parent, None, False, False, fit_type, top)
            elif fit_type == '/FitV' or '/FitBV':
                left = outline['/Left'] if outline['/Left'] != None else 0
                #print fit_type, left
                bookmark_node = pdf_writer.addBookmark(title, page_num + 1, parent, None, False, False, fit_type, left)
                
def merge_pdf_template(src_pdf_path, template_pdf_path, dst_pdf_path):
    try:
        template = PdfFileReader(template_pdf_path, strict = False)
        if template.getNumPages() < 2:
            print template_pdf_path, 'page num must >=2, page 0 for cover page 1 for watermark and header footer!!!!'
            return
        cover_page = template.getPage(0)
        watermark_page = template.getPage(1)
        pdf_reader = PdfFileReader(src_pdf_path, strict = False)
        #print pdf_reader.getDocumentInfo()
        #print pdf_reader.getNamedDestinations()
        pdf_outlines = pdf_reader.getOutlines()
        #analyze_outline(pdf_reader, pdf_outlines)
        
        pdf_writer = PdfFileWriter()
        pdf_writer.addPage(cover_page)
        if 1:
            #############################################################
            pdf_writer.appendPagesFromReader(pdf_reader)
            #pdf_writer.cloneDocumentFromReader(pdf_reader)
            #pdf_writer.cloneReaderDocumentRoot(pdf_reader)
            for page_index in range(pdf_reader.getNumPages()):
                pdf_page = pdf_writer.getPage(page_index)
                pdf_page.mergePage(watermark_page)
        else:
            for page_index in range(pdf_reader.getNumPages()):
                pdf_page = pdf_reader.getPage(page_index)
                pdf_page.mergePage(watermark_page)
                pdf_writer.addPage(pdf_page)
            #############################################################
        
        write_outline(pdf_reader, pdf_writer, pdf_outlines, None)
        pdfOutputFile = open(dst_pdf_path, 'wb')
        #pdf_writer.encrypt('qg2101')#设置pdf密码
        
        pdf_writer.write(pdfOutputFile)
        pdfOutputFile.close()
    except Exception, err:
        #print err
        print str(err).decode("string_escape")
    finally:
        print '===>', dst_pdf_path.decode('gbk')
        
if "__main__" == __name__:
    if len(sys.argv) < 3:
        print 'Para error.'
        print 'Usage: dir_path template_pdf_path'
        sys.exit(-1)
    print '\n------------------------------The Start-----------------------------'
    start_time = time.clock()
    
    target_path = sys.argv[1]
    target_path = os.path.abspath(target_path)
    template_pdf_path = sys.argv[2]
    template_pdf_path = os.path.abspath(template_pdf_path)
    print target_path, template_pdf_path
    for root, dirs, files in os.walk(target_path):
        for file in files:
            file_path = os.path.join(root, file)
            tmp_path, ext = os.path.splitext(file_path)
            if ext == '.pdf':
                if tmp_path.endswith('_QgTemplate'):
                    continue
                print '\n-----------------------', file_path.decode('gbk')
                merge_pdf_template(file_path, template_pdf_path, tmp_path + '_QgTemplate' + ext)

    print '\n------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)
    
