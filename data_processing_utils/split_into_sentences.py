from nltk.tokenize import sent_tokenize
from argparse import ArgumentParser
import pandas as pd
import os

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--input_file', type=str)
    parser.add_argument('--save_sentences_to', type=str)
    parser.add_argument('--save_doc_ids_to', type=str)
    args = parser.parse_args()

    chunk_id = 0
    sentences = 0
    if os.path.exists(args.save_sentences_to):
        os.remove(args.save_sentences_to)
    if os.path.exists(args.save_doc_ids_to):
        os.remove(args.save_doc_ids_to)
    with open(args.input_file, encoding='utf-8') as input_stream, \
            open(args.save_sentences_to, 'w', encoding='utf-8') as sentences_output_stream, \
            open(args.save_doc_ids_to, 'w', encoding='utf-8') as doc_ids_output_stream:
        for doc_id, line in enumerate(input_stream):
            sentences = sent_tokenize(line.strip())
            for sentence in sentences:
                sentences_output_stream.write(sentence + '\n')
                doc_ids_output_stream.write('{}'.format(doc_id) + '\n')
