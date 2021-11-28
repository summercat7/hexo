---
title: AC自动机
date: 2019-04-14 22:54:12
tags: 算法
categories: 算法
---
##AC自动机
```cpp
#include<iostream>
#include<cstdio>
#include<cstring>
#include<cstdlib>
#include<algorithm>

using namespace std;

const int N=1e6+9;

int n;
char ch[N];

struct AC_automaton
{
    int ch[N][27],cnt[N],fail[N],pool;
    int ed[N],q[N],l,r;

    inline void insert(char *s,int id)
    {
        int len=strlen(s+1),now=0;
        for(int i=1;i<=len;i++)
        {
            if(!ch[now][s[i]-'a'])
                ch[now][s[i]-'a']=++pool;
            now=ch[now][s[i]-'a'];
            cnt[now]++;
        }
        ed[id]=now;
    }

    inline void calc()
    {
        fail[0]=0;
        q[r=1]=l=0;

        while(l<r)
        {
            int u=q[++l];
            for(int i=0;i<26;i++)
                if(ch[u][i])
                {
                    q[++r]=ch[u][i];
                    fail[ch[u][i]]= u==0?0:ch[fail[u]][i];
                }
                else
                    ch[u][i]= u==0?0:ch[fail[u]][i];
        }

        for(int i=r;i>=1;i--)
            cnt[fail[q[i]]]+=cnt[q[i]];
        for(int i=1;i<=n;i++)
            printf("%d\n",cnt[ed[i]]);
    }
}koishi;

int main()
{
    scanf("%d",&n);
    for(int i=1;i<=n;i++)
    {
        scanf("%s",ch+1);
        koishi.insert(ch,i);
    }
    koishi.calc();
    return 0;
}
```
[参考](https://blog.csdn.net/zlttttt/article/details/77489295)