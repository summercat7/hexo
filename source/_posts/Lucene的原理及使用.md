---
title: Lucene的原理及使用
date: 2020-06-06 16:32:48
categories: Java
tags: 其他
---

## Lucene的原理及使用

#### 1、什么是全文检索

计算机索引程序通过扫描文章中的每一个词，对每一个词建立一个索引，指明该词在文章中出现的次数和位置，当用户查询时，检索程序就根据事先建立的索引进行查找，并将查找的结果反馈给用户的检索方式。

#### 2、Lucene的介绍

* Lucene是一套用于全文检索和搜寻的开源程序库。

* Lucene提供了一个简单却强大的应用程序接口（API），能够做全文索引和搜寻。

* Lucene并不是现成的搜索引擎产品，但可以用来制作搜索引擎产品。

#### 3、Lucene的存储结构

Lucene的索引结构是有层次结构的，主要分以下几个层次：

- 索引(Index)：

- - 一个目录一个索引，在Lucene中一个索引是放在一个文件夹中的。
  - 如左图，同一文件夹中的所有的文件构成一个Lucene索引。

- 段(Segment)：

- - 一个索引可以包含多个段，段与段之间是独立的，添加新文档可以生成新的段，不同的段可以合并。
    在建立索引的时候对性能影响最大的地方就是在将索引写入文件的时候, 所以在具体应用的时候就需要对此加以控制，段(Segment) 就是实现这种控制的。稍后详细描述段(Segment) 的控制策略。
  - 如上图，具有相同前缀文件的属同一个段，图中共两个段 "_0" 和 "_1"。
  - segments.gen和segments_5是段的元数据文件，也即它们保存了段的属性信息。

- 文档(Document)：

  - 文档是我们建索引的基本单位，不同的文档是保存在不同的段中的，一个段可以包含多篇文档。
  - 新添加的文档是单独保存在一个新生成的段中，随着段的合并，不同的文档合并到同一个段中。

- 域(Field)：

  - 一篇文档包含不同类型的信息，可以分开索引，比如标题，时间，正文，作者等，都可以保存在不同的域里。
  - 不同域的索引方式可以不同。

- 词(Term)：

  - 词是索引的最小单位，是经过词法分析和语言处理后的字符串。

#### 4、Lucene的使用

##### 4.1、索引库的创建和分词的使用

```java
import org.apache.commons.io.FileUtils;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.apache.lucene.document.*;
import org.apache.lucene.index.*;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.RAMDirectory;
import org.junit.Test;
import org.wltea.analyzer.lucene.IKAnalyzer;

import java.io.File;

public class LuceneFirst {
    @Test
    public void createIndex() throws Exception {
//1、创建一个Director对象，指定索引库保存的位置。
        //把索引库保存在内存中
        //Directory directory = new RAMDirectory();
        //把索引库保存在磁盘
        Directory directory = FSDirectory.open(new File("E:\\code\\java\\test\\luceneTemp\\index").toPath());
        //2、基于Directory对象创建一个IndexWriter对象
        IndexWriterConfig config = new IndexWriterConfig(new IKAnalyzer());
        IndexWriter indexWriter = new IndexWriter(directory, config);
        //3、读取磁盘上的文件，对应每个文件创建一个文档对象。
        File dir = new File("E:\\桌面文件\\other\\61.会员版(2.0)-就业课(2.0)-Lucene\\lucene\\02.参考资料\\searchsource");
        File[] files = dir.listFiles();
        for (File f :
                files) {
            //取文件名
            String fileName = f.getName();
            //文件的路径
            String filePath = f.getPath();
            //文件的内容
            String fileContent = FileUtils.readFileToString(f, "utf-8");
            //文件的大小
            long fileSize = FileUtils.sizeOf(f);
            //创建Field
            //参数1：域的名称，参数2：域的内容，参数3：是否存储
            Field fieldName = new TextField("name", fileName, Field.Store.YES);
            //Field fieldPath = new TextField("path", filePath, Field.Store.YES);
            Field fieldPath = new StoredField("path", filePath);
            Field fieldContent = new TextField("content", fileContent, Field.Store.YES);
            //Field fieldSize = new TextField("size", fileSize + "", Field.Store.YES);
            Field fieldSizeValue = new LongPoint("size", fileSize);
            Field fieldSizeStore = new StoredField("size", fileSize);
            //创建文档对象
            Document document = new Document();
            //向文档对象中添加域
            document.add(fieldName);
            document.add(fieldPath);
            document.add(fieldContent);
            //document.add(fieldSize);
            document.add(fieldSizeValue);
            document.add(fieldSizeStore);
            //5、把文档对象写入索引库
            indexWriter.addDocument(document);
        }
        //6、关闭indexwriter对象
        indexWriter.close();
    }

    @Test
    public void searchIndex() throws Exception {
        //1、创建一个Director对象，指定索引库的位置
        Directory directory = FSDirectory.open(new File("E:\\code\\java\\test\\luceneTemp\\index").toPath());
        //2、创建一个IndexReader对象
        IndexReader indexReader = DirectoryReader.open(directory);
        //3、创建一个IndexSearcher对象，构造方法中的参数indexReader对象。
        IndexSearcher indexSearcher = new IndexSearcher(indexReader);
        //4、创建一个Query对象，TermQuery
        Query query = new TermQuery(new Term("name", "spring"));
        //5、执行查询，得到一个TopDocs对象
        //参数1：查询对象 参数2：查询结果返回的最大记录数
        TopDocs topDocs = indexSearcher.search(query, 10);
        //6、取查询结果的总记录数
        System.out.println("查询总记录数：" + topDocs.totalHits);
        //7、取文档列表
        ScoreDoc[] scoreDocs = topDocs.scoreDocs;
        //8、打印文档中的内容
        for (ScoreDoc doc :
                scoreDocs) {
            //取文档id
            int docId = doc.doc;
            //根据id取文档对象
            Document document = indexSearcher.doc(docId);
            System.out.println(document.get("name"));
            System.out.println(document.get("path"));
            System.out.println(document.get("size"));
            //System.out.println(document.get("content"));
            System.out.println("-----------------");
        }
        //9、关闭IndexReader对象
        indexReader.close();
    }

    @Test
    public void testTokenStream() throws Exception {
        //1）创建一个Analyzer对象，StandardAnalyzer对象
//        Analyzer analyzer = new StandardAnalyzer();
        Analyzer analyzer = new IKAnalyzer();
        //2）使用分析器对象的tokenStream方法获得一个TokenStream对象
        TokenStream tokenStream = analyzer.tokenStream("", "查看分析器的效果");
        //3）向TokenStream对象中设置一个引用，相当于数一个指针
        CharTermAttribute charTermAttribute = tokenStream.addAttribute(CharTermAttribute.class);
        //4）调用TokenStream对象的rest方法。如果不调用抛异常
        tokenStream.reset();
        //5）使用while循环遍历TokenStream对象
        while(tokenStream.incrementToken()) {
            System.out.println(charTermAttribute.toString());
        }
        //6）关闭TokenStream对象
        tokenStream.close();
    }
}
```

##### 4.2、 索引库的维护（增删改）

```java
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StoredField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.FSDirectory;
import org.junit.Before;
import org.junit.Test;
import org.wltea.analyzer.lucene.IKAnalyzer;

import java.io.File;

public class IndexManager {
    private IndexWriter indexWriter;

    @Before
    public void init() throws Exception {
        //创建一个IndexWriter对象，需要使用IKAnalyzer作为分析器
        indexWriter =
                new IndexWriter(FSDirectory.open(new File("E:\\code\\java\\test\\luceneTemp\\index").toPath()),
                        new IndexWriterConfig(new IKAnalyzer()));
    }

    @Test
    public void addDocument() throws Exception {
        //创建一个IndexWriter对象，需要使用IKAnalyzer作为分析器
        IndexWriter indexWriter =
                new IndexWriter(FSDirectory.open(new File("E:\\code\\java\\test\\luceneTemp\\index").toPath()),
                        new IndexWriterConfig(new IKAnalyzer()));
        //创建一个Document对象
        Document document = new Document();
        //向document对象中添加域
        document.add(new TextField("name", "新添加的文件", Field.Store.YES));
        document.add(new TextField("content", "新添加的文件内容", Field.Store.NO));
        document.add(new StoredField("path", "E:\\code\\java\\test\\luceneTemp\\helo"));
        // 把文档写入索引库
        indexWriter.addDocument(document);
        //关闭索引库
        indexWriter.close();
    }

    @Test
    public void deleteAllDocument() throws Exception {
        //删除全部文档
        indexWriter.deleteAll();
        //关闭索引库
        indexWriter.close();
    }

    @Test
    public void deleteDocumentByQuery() throws Exception {
        indexWriter.deleteDocuments(new Term("name", "apache"));
        indexWriter.close();
    }

    @Test
    public void updateDocument() throws Exception {
        //创建一个新的文档对象
        Document document = new Document();
        //向文档对象中添加域
        document.add(new TextField("name", "更新之后的文档", Field.Store.YES));
        document.add(new TextField("name1", "更新之后的文档2", Field.Store.YES));
        document.add(new TextField("name2", "更新之后的文档3", Field.Store.YES));
        //更新操作
        indexWriter.updateDocument(new Term("name", "spring"), document);
        //关闭索引库
        indexWriter.close();
    }
}
```

##### 4.3、 索引库的查询

```java
import org.apache.lucene.document.Document;
import org.apache.lucene.document.LongPoint;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.FSDirectory;
import org.junit.Before;
import org.junit.Test;
import org.wltea.analyzer.lucene.IKAnalyzer;

import java.io.File;

public class SearchIndex {
    private IndexReader indexReader;
    private IndexSearcher indexSearcher;
    @Before
    public void init() throws Exception {
        indexReader = DirectoryReader.open(FSDirectory.open(new File("E:\\code\\java\\test\\luceneTemp\\index").toPath()));
        indexSearcher = new IndexSearcher(indexReader);
    }

    @Test
    public void testRangeQuery() throws Exception {
        //创建一个Query对象
        Query query = LongPoint.newRangeQuery("size", 0L, 100L);
        printResult(query);
    }

    private void printResult(Query query) throws Exception {
        //执行查询
        TopDocs topDocs = indexSearcher.search(query, 10);
        System.out.println("总记录数：" + topDocs.totalHits);
        ScoreDoc[] scoreDocs = topDocs.scoreDocs;
        for (ScoreDoc doc:scoreDocs){
            //取文档id
            int docId = doc.doc;
            //根据id取文档对象
            Document document = indexSearcher.doc(docId);
            System.out.println(document.get("name"));
            System.out.println(document.get("path"));
            System.out.println(document.get("size"));
            //System.out.println(document.get("content"));
            System.out.println("-----------------");
        }
        indexReader.close();
    }

    @Test
    public void testQueryParser() throws Exception {
        //创建一个QueryPaser对象，两个参数
        QueryParser queryParser = new QueryParser("name", new IKAnalyzer());
        //参数1：默认搜索域，参数2：分析器对象
        //使用QueryPaser对象创建一个Query对象
        Query query = queryParser.parse("lucene是一个Java开发的全文检索工具包");
        //执行查询
        printResult(query);
    }
}
```

