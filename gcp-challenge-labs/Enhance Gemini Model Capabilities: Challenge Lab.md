## 🚀 Enhance Gemini Model Capabilities: Challenge Lab | [GSP525](https://www.cloudskillsboost.google/course_templates/1241/labs/564289)

### Youtube link [Here]()

### 🌐 **Guide to Complete the Challenge Lab**

### Task 1. Open the notebook in Vertex AI Workbench ###
#### Task 1. Import libraries and install the Gen AI SDK
###### 1. Install Google Gen AI SDK for Python
2. Restart current runtime
3. Import Libraries
4. Set Google Cloud project information and initialize Google Gen AI SDK'
5. Load the Gemini 2.5 Flash model
######

### Task 2. Execute code with Gemini ###
In this task, you'll use the Gemini 2.5 Flash to write and execute Python code to perform a simple data analysis task, such as calculating the average price of a list of basketball sneakers.
 ### Generate and Execute Code using Gemini 2.5 Flash ###
 #### 1. Define the code execution tool
 ```bash
code_execution_tool = Tool(code_execution=ToolCodeExecution())
```
 #### 2. Define the prompt with the code to be executed
 ```bash
PROMPT = f"""Use Python to calculate the average price of the sneakers in the list:
{sneaker_prices}
Generate and run code for the calculation."""
```

### Task 3. Grounding with Google Search
##### In this task, you'll use Gemini 2.5 Flash with grounding to enhance the accuracy and relevance of Gemini's responses to questions about retail products.

##### 1. Define the Google Search tool
```bash
google_search_tool = Tool(google_search=GoogleSearch())
```

##### 2. Define the prompt with grounding
``` bash
prompt = "Find key features and price information for Nike Air Jordan XXXVI."
```
##### 3. Generate a response with grounding
```bash
response = client.models.generate_content(
    model=MODEL_ID,
    contents=prompt,
    config= GenerateContentConfig(
        tools=[google_search_tool],
        temperature=0
    ),
)

# Print the response
print(response.text)
```
#### Task 4. Extract Competitor Pricing and Structure Response with JSON Schema
##### In this task, you'll use Gemini 2.5 Flash to retrieve information about a basketball sneaker and its pricing sold by a competitor, returning the data in a structured format using a provided JSON schema.

##### 4. Loop through the sneaker models and retailers to extract pricing information
``` bash
for model in sneaker_models:
    for retailer in retailers:
        # 5. Construct the search query
        query = f"""Find the current price of {model} sold by {retailer}.
        If the price found is 0.00 return a random value between $50 and $200. DO NOT return 0.00."""
        # 6. Use Response Schema to extract the data
        response = client.models.generate_content(
            model=MODEL_ID,
            contents=query,
            config=GenerateContentConfig(
                response_schema= {
                    "type": "object",
                    "properties": {
                        "sneaker_model": {"type": "string"},
                        "retailer": {"type": "string"},
                        "price": {"type": "number"},
                        "currency": {"type": "string"}
                    },
                    "required": ["sneaker_model", "retailer", "price"]
                },
                response_mime_type="application/json"
            )
        )
        
        print(response.text)

```
