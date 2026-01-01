
from dotenv import load_dotenv
from pydantic import BaseModel
import json

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from langchain.agents import create_agent
from langchain.tools import tool
from langchain.messages import SystemMessage, HumanMessage
from langchain_openai import ChatOpenAI
from langgraph.checkpoint.memory import InMemorySaver

import yfinance as yf

load_dotenv() ## Load environment variables from .env file


app = FastAPI()

model = ChatOpenAI(
    model = 'c1/openai/gpt-5/v-20250930',
    base_url = 'https://api.thesys.dev/v1/embed/'
)

checkpointer = InMemorySaver()

@tool("get_stock_price", description="A function that returns the current stock price based on a ticker symbol")
def get_stock_price(ticker):
    stock = yf.Ticker(ticker)
    current_price = stock.history()["Close"].iloc[-1]
    ## print(f"The current stock price of {ticker} is {current_price}")
    return current_price
    
@tool('get_historical_stock_price', description='A function that returns the current stock price over time based on a ticker symbol and a start and end date.')
def get_historical_stock_price(ticker:str, start_date:str, end_date:str):
    stock = yf.Ticker(ticker)
    historical_prices = stock.history(start=start_date, end=end_date).to_dict()
    ## print(f"The historical stock prices of {ticker} from {start_date} to {end_date} are:\n{json.dumps(historical_prices, indent=2, default=str)}")
    return historical_prices


@tool('get_balance_sheet', description='A function that returns the balance sheet based on a ticker symbol.')
def get_balance_sheet(ticker:str):
    stock = yf.Ticker(ticker)
    balance_sheet = stock.balance_sheet
    ## print(f"The balance sheet of {ticker} is:\n{json.dumps(balance_sheet, indent=2, default=str)}")
    return balance_sheet

@tool('get_stock_news', description='A function that returns news based on a ticker symbol.')
def get_stock_news(ticker:str):
    stock = yf.Ticker(ticker)
    news = stock.news
    ##print(f"The news of {ticker} is:\n{json.dumps(news, indent=2, default=str)}")
    return news

agent = create_agent(
    model = model,
    checkpointer = checkpointer,
    tools = [get_stock_price, get_historical_stock_price, get_balance_sheet, get_stock_news]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}


class PromptObject(BaseModel):
    content:str
    id:str
    role:str


class RequestObject(BaseModel):
    prompt:PromptObject
    threadId:str
    responseId:str


@app.post('/api/chat')
async def chat(request: RequestObject):
    config = {'configurable': {'thread_id': request.threadId}}

    def generate():
        for token, _ in agent.stream(
            {'messages': [
                SystemMessage('You are a stock analysis assistant. You have the ability to get real-time stock prices, historical stock prices (given a date range), news and balance sheet data for a given ticker symbol.'),
                HumanMessage(request.prompt.content)
            ]},
            stream_mode='messages',
            config=config
        ):
            yield token.content

    return StreamingResponse(generate(), media_type='text/event-stream',
                             headers={
                                 'Cache-Control': 'no-cache, no-transform',
                                 'Connection': 'keep-alive',
                             })

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=8888)