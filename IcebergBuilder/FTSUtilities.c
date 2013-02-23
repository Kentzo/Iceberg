/*
Copyright (c) 2004-2005, Stephane Sudre
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "FTSUtilities.h"

#include <sys/param.h>
#include <sys/stat.h>
#include <err.h>
#include <errno.h>
#include <fts.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

int PBChown(int uid,int gid,const char * inPath)
{
    FTS * ftsp;
    FTSENT * tFile;
    char * tPath[2]={(char *)inPath,NULL};
    
    if ((ftsp = fts_open(tPath, FTS_PHYSICAL, 0)) == NULL)
    {
        return 1;
    }

    while ((tFile = fts_read(ftsp)) != NULL)
    {
        switch (tFile->fts_info)
        {
            case FTS_D:
            case FTS_SL:
            case FTS_SLNONE:
                    continue;
            case FTS_DNR:
            case FTS_ERR:
            case FTS_NS:
                    fts_close(ftsp);
                    
                    return 1;
            default:
                    break;
        }
        
        if (uid == tFile->fts_statp->st_uid && gid == tFile->fts_statp->st_gid)
        {
            continue;
        }
        
        if (chown(tFile->fts_accpath, uid, gid) == -1)
        {
            fts_close(ftsp);
            
            return 1;
        }
    }
    
    fts_close(ftsp);
    
    if (errno)
    {
        return 1;
    }
    
    return 0;
}

int PBRemoveDirectory(const char * inPath)
{
    FTS * ftsp;
    FTSENT * tFile;
    char * tPath[2]={(char *)inPath,NULL};
    
    if ((ftsp = fts_open(tPath, FTS_PHYSICAL, 0)) == NULL)
    {
        return 1;
    }
    
    while ((tFile = fts_read(ftsp)) != NULL)
    {
        switch (tFile->fts_info)
        {
            case FTS_DP:
            case FTS_F:
                if (remove(tFile->fts_path)!=0)
                {
                    fts_close(ftsp);
                    
                    return errno;
                }
                break;
            default:
                break;
        }
    }

    fts_close(ftsp);
    
    return 0;
}

int PBClean(const char * inPath,int inCleanDSStore,int inCleanPBDevelopment,int inCleanCVSAndSVN)
{
    FTS * ftsp;
    FTSENT * tFile;
    char * tPath[2]={(char *)inPath,NULL};
    
    if ((ftsp = fts_open(tPath, FTS_PHYSICAL, 0)) == NULL)
    {
        return 1;
    }
    
    while ((tFile = fts_read(ftsp)) != NULL)
    {
        switch (tFile->fts_info)
        {
            case FTS_DNR:
            case FTS_ERR:
            case FTS_NS:
                    fts_close(ftsp);
                    
                    return 1;
            case FTS_D:
            case FTS_SL:
            case FTS_SLNONE:
                continue;
            case FTS_F:
                
                if (inCleanDSStore==1)
                {
                    if (!strcasecmp(tFile->fts_name,".DS_Store"))
                    {
                        unlink(tFile->fts_path);
						
						break;
                    }
                }
                
                if (inCleanPBDevelopment==1)
                {
                    if (!strcasecmp(tFile->fts_name,"pbdevelopment.plist"))
                    {
                        unlink(tFile->fts_path);
						
						break;
                    }
                }
				
				if (inCleanCVSAndSVN==1)
                {
					if (!strcasecmp(tFile->fts_name,".cvsignore") ||
						!strcasecmp(tFile->fts_name,".cvspass"))
                    {
                        unlink(tFile->fts_path);
						
						break;
                    }
				}
                break;
            case FTS_DP:
                if (inCleanCVSAndSVN==1)
                {
                    if (!strcmp(tFile->fts_name,"CVS") ||
                        !strcmp(tFile->fts_name,".svn"))
                    {
                        if (PBRemoveDirectory(tFile->fts_path)==0)
                        {
                            // A COMPLETER
                        }
                    }
                }
                break;
            default:
                break;
        }
    }
    
    fts_close(ftsp);
    
    if (errno)
    {
        return 1;
    }
    
    return 0;
}

int64_t PBFolderSize4KRounded(const char * inPath)
{
    FTS * ftsp;
    FTSENT * tFile;
    char * tPath[2]={(char *)inPath,NULL};
    int64_t tFolderSize=0;
    
    if ((ftsp = fts_open(tPath, FTS_PHYSICAL, 0)) == NULL)
    {
        return -1;
    }

    while ((tFile = fts_read(ftsp)) != NULL)
    {
        u_int64_t tFileSize;
        
        switch (tFile->fts_info)
        {
            case FTS_D:
            case FTS_SL:
            case FTS_SLNONE:
                    continue;
            case FTS_DNR:
            case FTS_ERR:
            case FTS_NS:
                    fts_close(ftsp);
                    
                    return -1;
            default:
                    break;
        }
        
        tFileSize=tFile->fts_statp->st_size;
        
        tFolderSize+=((tFileSize+0xFFF)>>12)<<2;
    }
    
    fts_close(ftsp);
    
    return tFolderSize;
}