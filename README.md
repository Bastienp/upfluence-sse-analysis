# Upfluence SSE Stream analysis API

This is a coding challenge written in Ruby, it analyzes a SSE Stream provided by Upfluence to produce statistics. 

## Requirements
You can find the general specification here: https://gist.github.com/AlexisMontagne/222e8f1b41a2511021bd9ce7f9cd3b18

## Dependencies
- Ruby 3.1.3
- Rails 7.0.4

## Endpoint documentation
`GET /analysis/?duration=:duration&dimension=:dimension`
### Get statistics
```shell
curl "/analysis?duration=30s&dimension=likes"
```

Response:

```
{
    'total_posts' => 8,
    'maximum_timestamp' => 1659476150,
    'minimum_timestamp' => 1659476144,
    'likes_p50' => 0,
    'likes_p90' => 50,
    'likes_p99' => 50
}
```

### Parameters
| Parameter | Presence | Description                                                                                                                                                          |
|-----------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| duration  | required | Unit of time for which the API should analyze the stream. It should be an integer followed by one of these tokens `s` for seconds, `m` for minutes or `h` for hours. |
| dimension | required | The value we want to generate the statistics upon, it could be any of the following: `likes`, `comments`, `favorites`, `retweets`.                                   |

### Error codes

| Code                        | Description                                                                                                                                                      |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| invalid_duration_parameter  | The duration parameter should be an integer followed by one of these tokens `s` for seconds, `m` for minutes, or `h` for hours (i.e., `1s`, `245m`, `5h`, etc.). |
| invalid_dimension_parameter | The dimension parameter should be `likes`, `comments`, `favorites`, or `retweets`.                                                                               |

## Technical choices

### Statistic calculation
All the statistics are calculated using all the posts returned, even though they do not have the dimension. 
This means that if the post does not have the dimension for percentiles, the algorithm will use 0 as the value. 
It would be easy to modify the algorithm only to calculate statistics on posts with the dimension.

I implemented an easy way to calculate percentiles. The idea is to store values, sort them then take the index corresponding to the percentile.
This is inefficient the time complexity should be O(nlogn), and the space complexity should be O(n).
If the stream provides a lot of data, it might be impossible to store every value in the memory.

### Architecture
In order to analyze the Upfluence SSE stream, the `Analyze` service will analyze data returned by the `Upfluence::Sse::Listen` service, which retrieves data from the stream.

To avoid creating new connections to the SSE stream for each request to the `/analysis` endpoint, the `Upfluence::Sse::Listen` service has been implemented using the Singleton and Observable patterns.
The `Upfluence::Sse::Listen` service will be created only once and will be used for all requests, and the `Analyze` service can subscribe to it as an observer. 
When new data is received from the SSE stream, the `Upfluence::Sse::Listen` service will notify all of its observers.

To resume the flow:
- A user call `/analysis` endpoint with parameters.
- The controller ask to the service `Analyze` to compute statistics.
- The service `Analyze` subscribe to the SSE Stream as an observer of `Upfluence::Sse::Listen` and begins calculating the statistics.
- When we the requested duration has been reached the service returns statistics to the controller.

This architecture allows only one connection to the SSE stream to be used for multiple requests.


## Improvements

There are several areas for improvement in this solution, here are some of them:
- The current implementation for calculating percentiles is inefficient in terms of time and space complexity, as it requires storing and sorting dimension values.
  A more efficient approach would be to use an algorithm like the p-square algorithm (https://www.cse.wustl.edu/~jain/papers/ftp/psqr.pdf) that can approximate the percentile from the stream without storing any data.
  The solution has been thought with this in mind. The challenge is to code the p-square algorithm, which can be time-consuming. With p-square algorithm the time and space complexity becomes O(1).
- The solution is unreliable. If something goes wrong, the client will never receive the statistics. A more fault-tolerant approach would be to persist data from the SSE stream using a sliding window.
- The current solution involves waiting for the duration before responding to the client,
  which may not be realistic for long durations like 24 hours because it requires maintaining an open connection between the server and the client for the entire duration.
  An alternative approach would be to use background jobs to compute the statistics and implement a callback to inform the client when the analysis is complete.
- I focused on implementing the core functionality of the API, error handling could be improved.

## Run the project

Install Ruby (3.1.3 or higher) and the `bundler` gem.

install required dependencies:
```
bundle install
```

You can run the tests with the following command:
```
rspec
```

Launch the server:
```
rails s
```
The server will listen on the port `8080`
You can know start to analyze the SSE Stream, make a GET request to `http://localhost:8080/analysis?duration=10s&dimension=likes`
