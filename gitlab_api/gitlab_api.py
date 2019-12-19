#coding:utf-8
__author__ = 'zhangxiaodong'
import sys
import os
import codecs
import time
import shutil
import requests
import gitlab
from xml.dom.minidom import parse
import xml.dom.minidom

#import urllib3
#urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
requests.packages.urllib3.disable_warnings()

reload(sys)
sys.setdefaultencoding('utf8')

'''
gitlab.GUEST_ACCESS = 10
gitlab.REPORTER_ACCESS = 20
gitlab.DEVELOPER_ACCESS = 30
gitlab.MAINTAINER_ACCESS = 40
gitlab.OWNER_ACCESS = 50
'''


def simple_test():
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    url = r'https://192.168.19.105:8899/api/v4/projects?private_token=e7GayRAoKCrps1ojVYX5'
    try:
        print function_name
        ret = requests.get(url, verify = False)
        #print ret
        if ret != None:
            #print ret.json()
            print ret.status_code
        
        if ret.status_code == 200:
            print '=== status_code === ', ret.status_code  # 响应码
            print '=== headers === ', ret.headers  # 响应头
            print '=== Content-Type === ', ret.headers.get('Content-Type')  # 获取响应头中的Content-Type字段
        else:
            ret.raise_for_status()  # 抛出异常
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        print url
        
def delete_group_by_id(git_lab, group_id):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    groups = None
    try:
        print function_name, group_id
        group = git_lab.groups.get(group_id)
        if group:
            group.delete()
        else:
            print 'group [%d] not exist!!!!'
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return
        
def delete_group_by_name_path(git_lab, group_name, group_path, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    groups = None
    delete_flag = False
    try:
        print function_name, group_name, group_path, father_group_id
        if father_group_id == None:
            groups = git_lab.groups.list(all=True)
        else:
            father_group = git_lab.groups.get(father_group_id)
            groups = father_group.subgroups.list(all=True)
        for group in groups:
            if group.name == group_name and group.path == group_path:
                #print 'find the group [%d]'%group.id
                group.delete()
                delete_flag = True
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        if delete_flag:
            time.sleep(2)
        return delete_flag
        
########################## better not use this function
def delete_project_by_id(git_lab, project_id):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    project = None
    delete_flag = False
    try:
        print function_name, project_id
        project = git_lab.projects.get(project_id)
        if project:
                #print 'find the project [%d]'%project.id
                project.delete()
                delete_flag = True
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        if delete_flag:
            time.sleep(2)
        return delete_flag
        
########################## better not use this function
def delete_project_by_name_path(git_lab, project_name, project_path, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    projects = None
    delete_flag = False
    try:
        print function_name, project_name, project_path, father_group_id
        if father_group_id == None:
            projects = git_lab.projects.list(all=True)
        else:
            father_group = git_lab.groups.get(father_group_id)
            projects = father_group.projects.list(all=True)
        
        for project in projects:
            if project.name == project_name and project.path == project_path:
                #print 'find the project [%d]'%project.id
                project.delete()
                delete_flag = True
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        if delete_flag:
            time.sleep(2)
        return delete_flag
        
        
#####################################for example group_name /qg2101/brandy/lichee
def super_find_group_by_name_path(git_lab, super_name, super_path, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    groups = None
    group_id = None
    try:
        print function_name, super_name, super_path, father_group_id
        name_splits = super_name.split('/')
        path_splits = super_path.split('/')
        if len(name_splits) != len(path_splits):
            print 'name and path not in right format!', project_name, project_path
        else:
            final_find_flag = True
            
            for i, tmp_path in enumerate(path_splits):
                tmp_name = name_splits[i]
                if father_group_id == None:
                    groups = git_lab.groups.list(all=True)
                else:
                    father_group = git_lab.groups.get(father_group_id)
                    groups = father_group.subgroups.list(all=True)
                tmp_find_flag = False
                for group in groups:
                    if group.name == tmp_name and group.path == tmp_path:
                        tmp_find_flag = True
                        father_group_id = group.id
                if tmp_find_flag == False:
                    final_find_flag = False
                    break
                        
            if final_find_flag == True:
                group_id = father_group_id
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return group_id
        
#####################################for example project_name /qg2101/brandy/lichee
def super_find_project_by_name_path(git_lab, super_name, super_path, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    groups = None
    projects = None
    project_id = None
    try:
        print function_name, super_name, super_path, father_group_id
        name_splits = super_name.split('/')
        path_splits = super_path.split('/')
        if len(name_splits) != len(path_splits):
            print 'name and path not in right format!', project_name, project_path
        else:
            final_find_flag = True
            
            for i, tmp_path in enumerate(path_splits):
                tmp_name = name_splits[i]
                if i == len(path_splits) - 1:#run into last '/', project level
                    if father_group_id == None:
                        projects = git_lab.projects.list(all=True)
                    else:
                        father_group = git_lab.groups.get(father_group_id)
                        projects = father_group.projects.list(all=True)
                    tmp_find_flag = False
                    for project in projects:
                        if project.name == tmp_name and project.path == tmp_path:
                            tmp_find_flag = True
                            project_id = project.id
                else:
                    if father_group_id == None:
                        groups = git_lab.groups.list(all=True)
                    else:
                        father_group = git_lab.groups.get(father_group_id)
                        groups = father_group.subgroups.list(all=True)
                    tmp_find_flag = False
                    for group in groups:
                        if group.name == tmp_name and group.path == tmp_path:
                            tmp_find_flag = True
                            father_group_id = group.id
                if tmp_find_flag == False:
                    final_find_flag = False
                    break
                        
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return project_id
        
#####################################for example group_name /qg2101/brandy/lichee
def super_create_group_by_name_path(git_lab, super_name, super_path, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    group_id = None
    try:
        print function_name, super_name, super_path, father_group_id
        name_splits = super_name.split('/')
        path_splits = super_path.split('/')
        if len(name_splits) != len(path_splits):
            print 'name and path not in right format!', project_name, project_path
        else:
            final_create_flag = True
            
            for i, tmp_path in enumerate(path_splits):
                tmp_name = name_splits[i]
                tmp_id = super_find_group_by_name_path(git_lab, tmp_name, tmp_path, father_group_id)
                if tmp_id == None:
                    father_group_id = create_group(git_lab, tmp_name, tmp_path, tmp_name)
                    if father_group_id == None:
                        final_create_flag = False
                        break
                else:
                    father_group_id = tmp_id
            if final_create_flag == True:
                group_id = father_group_id
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return group_id
        
#####################################for example group_name /qg2101/brandy/lichee
def super_create_project_by_name_path(git_lab, super_name, super_path,father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    project_id = None
    try:
        print function_name, super_name, super_path, father_group_id
        name_splits = super_name.split('/')
        path_splits = super_path.split('/')
        if len(name_splits) != len(path_splits):
            print 'name and path not in right format!', project_name, project_path
        else:
            final_create_flag = True
            
            for i, tmp_path in enumerate(path_splits):
                tmp_name = name_splits[i]
                if i == len(path_splits) - 1:
                    tmp_id = super_find_project_by_name_path(git_lab, tmp_name, tmp_path, father_group_id)
                    if tmp_id == None:
                        project_id = create_project(git_lab, tmp_name, tmp_path, tmp_name, father_group_id)
                    else:
                        project_id = tmp_id
                else:
                    tmp_id = super_find_group_by_name_path(git_lab, tmp_name, tmp_path, father_group_id)
                    if tmp_id == None:
                        father_group_id = create_group(git_lab, tmp_name, tmp_path, tmp_name, father_group_id)
                        if father_group_id == None:
                            final_create_flag = False
                            break
                    else:
                        father_group_id = tmp_id
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return group_id
        
def list_groups(git_lab, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    groups = None
    try:
        print function_name, father_group_id
        if father_group_id == None:
            groups = git_lab.groups.list(all=True)
        else:
            father_group = git_lab.groups.get(father_group_id)
            groups = father_group.subgroups.list(all=True)
        #print groups
        for group in groups:
            print '----------------'
            print group.id, group.name, group.path, group.description
            
            # members = group.members.all(all=True)
            # for member in members:
                # print '---', member.username, member.access_level
                # if member.username == 'xiaodongzhang':
                    # print member.username, member.access_level
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return groups
    
def list_projects(git_lab, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    projects = None
    try:
        print function_name, father_group_id
        if father_group_id == None:
            projects = git_lab.projects.list(all=True)
        else:
            father_group = git_lab.groups.get(father_group_id)
            projects = father_group.projects.list(all=True)
        #print projects
        for project in projects:
            print '----------------'
            print project.id, project.name, project.path, project.description
            # members = project.members.all(all=True)
            # for member in members:
                # print '---', member.username, member.access_level
                # if member.username == 'xiaodongzhang':
                    # print member.username, member.access_level
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return projects
        
        
def create_group(git_lab, group_name, group_path, group_desc, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    group_id = 0
    try:
        print function_name, group_name, group_path, father_group_id
        #group_name = 'gitlab_api_group_test'
        #group_path = 'gitlab_api_group_test'
        #group_desc = 'gitlab_api_group_test description'
        if father_group_id == None:
            group = git_lab.groups.create({'name': group_name, 'path': group_path})
        else:
            group = git_lab.groups.create({'name': group_name, 'path': group_path, 'parent_id': father_group_id})
        group.description = group_desc
        group.save()
        group_id = group.id
        print group.id, group.name, group.path, group.description
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        time.sleep(2)
        return group_id
        
def create_project(git_lab, project_name, project_path, project_desc, father_group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    project_id = 0
    try:
        print function_name, project_name, project_path, father_group_id
        #project_name = 'gitlab_api_project_test'
        #project_path = 'gitlab_api_project_test'
        #project_desc = 'gitlab_api_project_test description'
        
        if father_group_id == None:
            project = git_lab.projects.create({'name': project_name, 'path': project_path})
        else:
            project = git_lab.projects.create({'name': project_name, 'path': project_path, 'namespace_id': father_group_id})
        project.description = project_desc
        project.save()
        project_id = project.id
        print project.id, project.name, project.path, project.description
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        time.sleep(2)
        return project_id
        
        
def update_project_emails_onpush_list(git_lab, project_id):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    try:
        emails = ''
        project = git_lab.projects.get(project_id)
        if project:
            print function_name, 'find the project [%d]'%project.id
            project_services = project.services
            #print dir(project_services)
            #print project_services
            if project_services:
                print '    service [Emails on push]===>'
                service = project_services.get('emails-on-push')

                attributes = service.attributes
                #properties = attributes['properties']
                properties = service.properties

                members = project.members.all(all=True)
                for member in members:
                    #print member
                    #print dir(member)
                    user = git_lab.users.get(member.id)
                    print '    ', member.id, user.email
                    emails = emails + ' ' + user.email
                service.properties[u'recipients'] = emails

                #service.active = False
                #service.__setattr__('active', service.active)
                service.__setattr__('recipients', service.properties[u'recipients'])
                print '    ---->', service._updated_attrs
                service.save()
            project.save()
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return emails
        
def update_group_emails_onpush_list(git_lab, group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    projects = None
    try:
        print function_name, group_id
        if group_id == None:
            projects = git_lab.projects.list(all=True)
        else:
            father_group = git_lab.groups.get(group_id)
            ##################support subgroups
            sub_groups = father_group.subgroups.list(all=True)
            for sub_group in sub_groups:
                update_group_emails_onpush_list(git_lab, sub_group.id)
            ##################
            projects = father_group.projects.list(all=True)
        #print projects
        for project in projects:
            print '----------------'
            print project.id, project.name, project.path, project.description
            update_project_emails_onpush_list(git_lab, project.id)
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return projects
        
        
def project_branches_protect_crtl(git_lab, protect_ctrl, project_id):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    try:
        branches = ''
        project = git_lab.projects.get(project_id)
        if project:
            print function_name, 'find the project [%d]'%project.id
            project_branches = project.branches.list()
            #print project_branches
            for project_branch in project_branches:
                #print function_name, project_branch
                if protect_ctrl == 'protect':
                    project_branch.protect()
                else:
                    project_branch.unprotect()
            project.save()
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return branches
    
def group_branches_protect_crtl(git_lab, protect_ctrl, group_id = None):
    function_name = '---> %s\n     '%( sys._getframe().f_code.co_name)
    projects = None
    try:
        print function_name, group_id
        if group_id == None:
            projects = git_lab.projects.list(all=True)
        else:
            father_group = git_lab.groups.get(group_id)
            ##################support subgroups
            sub_groups = father_group.subgroups.list(all=True)
            for sub_group in sub_groups:
                group_branches_protect_crtl(git_lab, protect_ctrl, sub_group.id)
            ##################
            projects = father_group.projects.list(all=True)
        #print projects
        for project in projects:
            print '----------------'
            print project.id, project.name, project.path, project.description
            project_branches_protect_crtl(git_lab, protect_ctrl, project.id)
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        return projects
        
if "__main__" == __name__:
    if len(sys.argv) < 2:
        print 'Para error.'
        print 'Usage: cmd_type(0: for create projects, 1: for update projects email onpush list )'
        sys.exit(-1)
    print '\n------------------------------The Start-----------------------------'
    start_time = time.clock()
    #####################################################
    #url = r'https://192.168.19.105:8899'
    #token = 'e7GayRAoKCrps1ojVYX5' #105 xiaodongzhang1025@163.com
    #token = 'w5u26Aw8Gu4U2v7kcNKN' #105 root
    
    url = r'http://192.168.19.141'
    token = 'AB4NKyVwhwVAgGc-nE7z' #141 root
    
    try:
        session = requests.Session()
        session.verify = False
        #session.cert = ('/path/to/client.cert', '/path/to/client.key')
        git_lab = gitlab.Gitlab(url, token, api_version=4, session=session)
        if sys.argv[1] == '0':
            #projects = git_lab.projects.list(all=True)
            #print projects
            #list_groups(git_lab)
            #list_projects(git_lab)
            #delete_project_by_name_path(git_lab, 'gitlab_api_project_test', 'gitlab_api_project_test')
            #delete_group_by_name_path(git_lab, 'gitlab_api_subgroup_test', 'gitlab_api_subgroup_test')
            delete_group_by_name_path(git_lab, 'gitlab_api_group_test', 'gitlab_api_group_test')
            #######################create group
            group_id = create_group(git_lab, 'gitlab_api_group_test', 'gitlab_api_group_test', 'gitlab_api_group_test desc')
            if group_id == None:
                print 'create_group failed\n'
                sys.exit(-1)
            #######################create project in a group
            DOMTree = xml.dom.minidom.parse("manifest.xml")
            elementobj = DOMTree.documentElement
            subElementObjs = elementobj.getElementsByTagName("project")
            for i, subElementObj in enumerate(subElementObjs):
                project_name = subElementObj.getAttribute("name")
                project_path = subElementObj.getAttribute("path")
            
                ##manifest.xml
                project_name = project_path
                print 'project info:', project_name, project_path
                super_create_project_by_name_path(git_lab, project_name, project_path, father_group_id = group_id)
        elif sys.argv[1] == '1':
            #update_project_emails_onpush_list(git_lab, 146) #xiaodong project
            update_group_emails_onpush_list(git_lab, 126) #xiaodong group
        elif sys.argv[1] == '2':
            group_branches_protect_crtl(git_lab, 'unprotect', 126) #xiaodong group
        elif sys.argv[1] == '3':
            group_branches_protect_crtl(git_lab, 'protect', 126) #xiaodong group
        else:
            print 'unsupported cmd_type!!!'
    except Exception, err:
        #print err
        print '===> Exception'
        print str(err).decode("string_escape")
    finally:
        #print '===> Finally'
        print '\n\nyour url and token info:', url, token
    #####################################################
    print '------------------------------The   End-----------------------------'
    end_time = time.clock()
    print 'Time used %s senconds'%(end_time - start_time)
    sys.exit(0)