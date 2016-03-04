'''
Created on 2 Mar 2016

@author: aaron
'''
from ubuntu_sso.keyring.pykeyring import USERNAME
from yaml import dump, load
import os,requests, uuid
import json

GITHUB_API="https://api.github.com/"
CLIENT_ID="0a68d223de982e650c04"
CLIENT_SECRET="399f6072804f110a031c7c67f7a8132700ad3af0"
class Idea(object):
    def __init__(self,raw):
        self.raw = raw
        self.name = raw['name']
        self.commits = {} 
        self.forks =[]
        self.meta_datas={}

    def addCommit(self,commit): 
        if not self.commits.has_key(commit.id):
            self.commits[commit.id]=commit
        return
        
    def crawl(self):
        # get all forks recursively
        getAllFolks(self, self.raw)
        for fork in self.forks:
            #print fork["name"]
            commits_url = fork["commits_url"].replace("{/sha}","?sha=gh-pages")
            print commits_url
            commits = getUrl(commits_url)
            #assume order by time
            print len(commits)
            for c in reversed(commits):
                if self.commits.has_key(c["sha"]):
                    continue
                commit = Commit(c,self)
                self.addCommit(commit)
            #add fork to the last commit 
            c = commits[0]
            commit = self.commits[c["sha"]]
            commit.addFolks(fork)
        #get all meta data
        for commit in self.commits.values():
            #set children info 
            for parent in commit.getParents(): 
                parent.addChildren(commit)
            for fork in commit.forks.values():
                meta_data = getMetaData(fork)
                if meta_data:
                    self.addMetaData(meta_data)
                pass
        
    def addMetaData(self,meta_data):       
        #TODO    
        def getHashId(meta_data):
            return str(uuid.uuid4()) 

        id = getHashId(meta_data)
        if not self.meta_datas.has_key(id):
            self.meta_datas[id]=meta_data
        return       
    
    def render(self,out_path):
        out = dump(self.meta_datas.values()) 
        f= open(os.path.join(out_path,self.name+".yml"),"w") 
        f.write(out)
        f.close()
        return

def getMetaData(fork):            
    #TODO
    return dict(
                name="test",
                )
                
def getAllFolks(idea,fork): 
        idea.forks.append(fork)
        if fork["forks_count"] > 0 :
            forks = getUrl(fork["forks_url"])
            for f in forks:
                getAllFolks(idea, f)

class Commit(object):
    def __init__(self,raw,idea):
        self.raw = raw
        self.id = raw["sha"]
        self.parents ={} 
        self.children = {}
        self.forks = {}
        for p in raw["parents"]:
            parent = idea.commits[p["sha"]] 
            self.parents[parent.id]=parent
        
    def addParent(self,parent):
        if not self.parents.has_key(parent.id):
            self.parents[parent.id]=parent
        return
    def getParents(self):
        return self.parents.values()
    def addChildren(self,child):
        if not self.parents.has_key(child.id):
            self.parents[child.id]=child
        return
    def addFolks(self,fork):
        if not self.forks.has_key(fork["id"]):
            self.forks[fork["id"]]=fork
        return
    def __str__(self):
        return str(self.__unicode__())

    def __unicode__(self):
        return dict(
                id=self.id,
                parents=self.parents,
                forks =self.forks,
                    )
class IdeaCrawler(object):
    '''
    crawl ideas from github user or organization
    '''


    def __init__(self, orgs_name,path):
        '''
        Constructor
        '''
        self.orgs_name = orgs_name 
        self.output_path = path
        self.ideas=[]
         
    def crawl(self):
        repos = getOrgsRepo(self.orgs_name)
        for repo in repos:
            if str(repo["description"]).startswith("unhidea-idea"):
                idea = Idea(repo)
                self.ideas.append(idea)
                idea.crawl()
    def render(self):
        
        for idea in self.ideas:
            idea.render(self.output_path)
                
def getOrgsRepo(orgs_name):                     
    url = GITHUB_API+"orgs/"+orgs_name+"/repos"        
    return getUrl(url)        

def getUserRepo(user_name):                     
    url = GITHUB_API+"users/"+user_name+"/repos"        
    return getUrl(url)        

def getUrl(url):
    if url.find("?")== -1:
        url+="?1=1"
    url+="&client_id="+CLIENT_ID+"&client_secret="+CLIENT_SECRET
    r = requests.get(url)
    if not r.status_code == 200:
        print "error return code", r.status_code
        return None
    else:
        return r.json()
 
if __name__ == "__main__":
    crawler = IdeaCrawler("unhidea","../../dist")
    crawler.crawl()
    crawler.render()