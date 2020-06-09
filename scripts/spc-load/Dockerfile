FROM python:3.6

WORKDIR /load

COPY requirements.txt /load/

RUN pip install -r requirements.txt

COPY entrypoint.sh /load/
COPY spc-load.py /load/

CMD ["./entrypoint.sh"]
