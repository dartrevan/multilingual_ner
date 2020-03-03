from argparse import ArgumentParser
import json


def extract_entities(tokens, labels):
    entities = []
    text_entities = []
    entity = []
    for token, label in zip(tokens, labels):
        if (label == 'O' or label.startswith('B-')) and len(entity) > 0:
            text_entities.append({'span': entity})
            entity = []
        if label.startswith('B-'):
            entity.append(token)
        if label.startswith('I-'):
            entity.append(token)
    return entities


def read(tokens_file, labels_file):
    with open(tokens_file, encoding='utf-8') as tokens_input_stream, \
            open(labels_file, encoding='utf-8') as labels_input_stream:
        tokens = []
        labels = []
        for token, label in zip(tokens_input_stream, labels_input_stream):
            token = token.strip()
            label = label.strip()
            if token == '[CLS]': continue
            if token == '[SEP]':
                yield tokens, labels
                tokens = []
                labels = []
                continue
            if token[:2] == '##':
                if len(tokens) == 0:
                    tokens.append('')
                tokens[-1] += token[2:]
                continue
            tokens.append(token)
            labels.append(label)
    if len(tokens) != 0:
        yield tokens
        yield labels


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--tokens')
    parser.add_argument('--labels')
    parser.add_argument('--save_to')
    args = parser.parse_args()

    with open(args.save_to, 'w', encoding='utf-8') as output_stream:
        for tokens, labels in read(args.tokens, args.labels):
            text_entities = extract_entities(tokens, labels)
            serialized_output_str = json.dumps(text_entities)
            output_stream.write(serialized_output_str + '\n')
