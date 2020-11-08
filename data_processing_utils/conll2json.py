from utils import save_json_file
from argparse import ArgumentParser
import json


def iter_sentences(path):
    tweet_entities = []
    entity = []
    text = []
    token_start = 0
    token_end = 0
    with open(path, encoding='utf-8') as input_stream:
        for line in input_stream:
            if line == '\n':
                if len(entity) > 0:
                    tweet_entities.append(entity)
                yield {'text': ' '.join(text), 'entities': tweet_entities}
                text = []
                tweet_entities = []
                entity = {}
                token_start = 0
                token_end = 0
                continue
            token, label = line.strip().split()
            text.append(token)
            token_start = token_end + 1 if token_end else 0
            token_end = token_start + len(token)
            if (label == 'O' or label.startswith('B-')) and len(entity) > 0:
                tweet_entities.append(entity)
                entity = []
            if label.startswith('B-') or (len(entity) == 0 and label.startswith('I-')):
                entity = {
                    'text': token,
                    'type': label.split('-')[1],
                    'start': token_start,
                    'end': token_end
                }
            elif label.startswith('I-'):
                entity['text'] += ' ' + token
                entity['end'] = token_end
        if len(text) > 0:
            yield {'text': ' '.join(text), 'entities': tweet_entities}


def correct_spans(sentence, offset):
    for entity in sentence['entities']:
        entity['start'] += offset
        entity['end'] += offset


def append_sentence_to_document(document, sentence):
    offset = len(document['text'])
    if offset != 0:
        document['text'] += ' '
        offset += 1
    document['text'] += sentence['text']
    correct_spans(sentence, offset)
    document['entities'] += sentence['entities']


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--conll_file', help='')
    parser.add_argument('--save_to', help='')
    #parser.add_argument('--document_ids', type=str, help='')
    args = parser.parse_args()

    data = {}
    prev_doc_id = None
    document = {}
    with open(args.save_to, 'w', encoding='utf-8') as output_stream:
      for document_id, document_sentence in enumerate(iter_sentences(args.conll_file)):
        if  prev_doc_id is None or  prev_doc_id != document_id:
          if prev_doc_id is not None:
            output_stream.write(json.dumps(document, ensure_ascii=False) + '\n')
          document = {
              'document_id': document_id,
              'text': '',
              'entities': []
          }
        #else:
        append_sentence_to_document(document, document_sentence)
        prev_doc_id = document_id
      output_stream.write(json.dumps(document, ensure_ascii=False) + '\n')
    #data = [document for document_id, document in data.items()]
    #save_json_file(data, args.save_to, args.jsonl)
