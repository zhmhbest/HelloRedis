package org.example.es;

import org.apache.http.HttpHost;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexRequest;
import org.elasticsearch.action.bulk.BulkRequest;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.delete.DeleteRequest;
import org.elasticsearch.action.delete.DeleteResponse;
import org.elasticsearch.action.get.GetRequest;
import org.elasticsearch.action.get.GetResponse;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.support.master.AcknowledgedResponse;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.action.update.UpdateResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.indices.CreateIndexRequest;
import org.elasticsearch.client.indices.CreateIndexResponse;
import org.elasticsearch.client.indices.GetIndexRequest;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.index.query.TermQueryBuilder;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * Elasticsearch
 * https://www.elastic.co/guide/en/elasticsearch/client/java-rest/7.x/java-rest-high-supported-apis.html
 */
public class AppHighLevel {
    public static void demoIndex(RestHighLevelClient client, String indexName, boolean isRemove) throws IOException {
        GetIndexRequest getIndexRequest = new GetIndexRequest(indexName);
        boolean isExist = client.indices().exists(getIndexRequest, RequestOptions.DEFAULT);
        if (!isExist) {
            // 测试创建
            CreateIndexRequest createIndexRequest = new CreateIndexRequest(indexName);
            CreateIndexResponse createIndexResponse =
                    client.indices().create(createIndexRequest, RequestOptions.DEFAULT);
            System.out.println("创建索引：" + createIndexResponse.index());
        }
        if (isRemove) {
            // 测试删除
            DeleteIndexRequest deleteIndexRequest = new DeleteIndexRequest(indexName);
            AcknowledgedResponse acknowledgedResponse =
                    client.indices().delete(deleteIndexRequest, RequestOptions.DEFAULT);
            System.out.println("删除索引：" + acknowledgedResponse.isAcknowledged());
        }
    }

    public static void demoDocument(RestHighLevelClient client, String indexName, String docID) throws IOException {
        GetRequest getRequest = new GetRequest(indexName, docID);
        boolean isExist = client.exists(getRequest, RequestOptions.DEFAULT);
        if (!isExist) {
            // 测试创建
            IndexRequest request = new IndexRequest(indexName);
            request.id("1");
            request.timeout(TimeValue.timeValueSeconds(10));
            request.source(getRandomOne());
            IndexResponse response = client.index(request, RequestOptions.DEFAULT);
            System.out.println("创建文档：" + response.status());
        }
        {
            // 测试更新
            UpdateRequest updateRequest = new UpdateRequest(indexName, docID);
            Map<String, Object> one = new HashMap<>();
            one.put("name", "小王");
            updateRequest.doc(one);
            UpdateResponse updateResponse = client.update(updateRequest, RequestOptions.DEFAULT);
            System.out.println("更新文档：" + updateResponse.status());
        }
        {
            // 测试读取
            GetRequest getRequestContent = new GetRequest(indexName, docID);
            GetResponse getResponseContent = client.get(getRequestContent, RequestOptions.DEFAULT);
            Map<String, Object> one = getResponseContent.getSource();
            System.out.println("获取文档：" + one);
        }
        {
            // 测试删除
            DeleteRequest deleteRequest = new DeleteRequest(indexName, docID);
            DeleteResponse deleteResponse = client.delete(deleteRequest, RequestOptions.DEFAULT);
            System.out.println("删除文档：" + deleteResponse.status());
        }
    }

    public static void demoBatchInsert(RestHighLevelClient client, String indexName) throws IOException {
        BulkRequest bulkRequest = new BulkRequest();
        bulkRequest.timeout(TimeValue.timeValueSeconds(10));
        ArrayList<Map<String, Object>> docList = new ArrayList<>();
        // 生成
        for (int i = 0; i < 300; i++) {
            docList.add(getRandomOne());
        }
        // 添加
        int id = 1000;
        for (Map<String, Object> item : docList) {
            bulkRequest.add(new IndexRequest(indexName).id(Integer.toString(id)).source(item));
            id++;
        }
        // 提交
        BulkResponse bulkResponse = client.bulk(bulkRequest, RequestOptions.DEFAULT);
        System.out.println("批量插入：" + bulkResponse.status());
        if (bulkResponse.hasFailures()) {
            System.out.println("批量插入失败");
        }
    }

    public static void demoSearch(RestHighLevelClient client, String indexName) throws IOException {
        final int batchSize = 10;
        SearchRequest searchRequest = new SearchRequest(indexName);
        SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder()
                // .query(QueryBuilders.matchQuery("name", "text"))
                // .query(QueryBuilders.termQuery("name", "value"))
                // .query(QueryBuilders.rangeQuery("name").from("").to(""))
                // .query(QueryBuilders.boolQuery().?()) // should | must | mustNot
                .query(QueryBuilders.rangeQuery("birth").from("1995-01-01").to("2000-01-01"))
                .timeout(new TimeValue(10, TimeUnit.SECONDS))
                .from(0)
                .size(batchSize);
        searchRequest.source(searchSourceBuilder);
        SearchResponse searchResponse = client.search(searchRequest, RequestOptions.DEFAULT);
        SearchHits searchHits = searchResponse.getHits();
        System.out.println("命中：" + batchSize + "/" + searchHits.getTotalHits().value);
        int index = 1;
        for (SearchHit searchHit : searchResponse.getHits()) {
            Map<String, Object> one = searchHit.getSourceAsMap();
            System.out.println(index + ":" + one);
            index++;
        }
    }

    private static Map<String, Object> getRandomOne() {
        boolean gender = RandomMessage.random.nextBoolean();
        Map<String, Object> one = new HashMap<>();
        one.put("name", RandomMessage.randomName(gender));
        one.put("comment", "评价" + RandomMessage.random.nextFloat());
        one.put("gender", gender);
        one.put("birth", RandomMessage.randomBirthday());
        one.put("weight", 100 * RandomMessage.random.nextFloat());
        one.put("class", RandomMessage.randomInteger(100, 105));
        return one;
    }

    public static void main(String[] args) throws IOException {
        final String indexName = "student10";
        final String docId = "1";
        RestHighLevelClient client = new RestHighLevelClient(RestClient.builder(
                new HttpHost("localhost", 9200, "http")
        ));
        demoIndex(client, indexName, false);
        demoDocument(client, indexName, docId);
        demoBatchInsert(client, indexName);
        demoSearch(client, indexName);
        client.close();
    }
}