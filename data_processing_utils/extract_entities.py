from argparse import ArgumentParser
import csv
import json


def extract_entities(tokens, labels):
    entities = []
    entity = []
    for token, label in zip(tokens, labels):
        if (label == 'O' or label.startswith('B-')) and len(entity) > 0:
            entities.append({'span': ' '.join(entity)})
            entity = []
        if label.startswith('B-'):
            entity.append(token)
        if label.startswith('I-'):
            entity.append(token)
    return entities


def read_doc_ids(doc_ids_path):
    with open(doc_ids_path, encoding='utf-8') as input_stream:
        for line in input_stream:
            yield line.strip().split('\t')


def read_input_file(input_file_path):
    with open(input_file_path, encoding='utf-8') as input_stream:
        patents_reader = csv.reader(input_stream, delimiter=',', quotechar='"')
        headers = next(patents_reader, None)
        for row in patents_reader:
            yield {key: value for key, value in zip(headers, row)}


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
    parser.add_argument('--tokens_dis')
    parser.add_argument('--labels_dis')
    parser.add_argument('--tokens_gene')
    parser.add_argument('--labels_gene')
    parser.add_argument('--input_file')
    parser.add_argument('--doc_ids')
    parser.add_argument('--save_to')
    args = parser.parse_args()

    abstracts_stream = read_input_file(args.input_file)
    with open(args.save_to, 'w', encoding='utf-8') as output_stream:
        writer = csv.writer(output_stream, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(['_id', 'title', 'abstract', 'entities', 'logits'])

        disease_input_stream = read(args.tokens_dis, args.labels_dis)
        gene_input_stream = read(args.tokens_gene, args.labels_gene)
        doc_ids_stream = read_doc_ids(args.doc_ids)

        prev_doc_id = None
        gene_entities = []
        disease_entities = []

        for (doc_id, title), (tokens_dis, labels_dis), (tokens_gen, labels_gen) \
                in zip(doc_ids_stream, disease_input_stream, gene_input_stream):
            g_entities = extract_entities(tokens_gen, labels_gen)
            d_entities = extract_entities(tokens_dis, labels_dis)
            if doc_id == prev_doc_id or prev_doc_id is None:
                gene_entities += g_entities
                disease_entities += d_entities
            else:
                abstract = next(abstracts_stream)
                entities = json.dumps({'disease': disease_entities, 'genes': gene_entities})
                output_row = [doc_id, title, abstract['abstract'], entities, []]
                writer.writerow(output_row)
                disease_entities = []
                gene_entities = []
            prev_doc_id = doc_id

