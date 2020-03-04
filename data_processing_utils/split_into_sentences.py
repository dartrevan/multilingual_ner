from nltk.tokenize import sent_tokenize
from argparse import ArgumentParser
import pandas as pd


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--input_file', type=str)
    parser.add_argument('--save_sentences_to', type=str)
    parser.add_argument('--save_doc_ids_to', type=str)
    parser.add_argument('--chunksize', type=int, default=10000)
    args = parser.parse_args()

    chunk_id = 0
    sentences = 0
    for chunk in pd.read_csv(args.input_file, chunksize=args.chunksize, usecols=['_id', 'project_title', 'abstract']):
        chunk['abstract_sentences'] = chunk.abstract.str.replace('\n', ' ').apply(sent_tokenize)
        chunk = chunk[['_id', 'project_title', 'abstract_sentences']]
        chunk = chunk.explode('abstract_sentences')
        chunk[['_id', 'project_title']].to_csv(args.save_doc_ids_to, index=False,
                                               header=None, sep='\t', encoding='utf-8', mode='a')
        chunk.abstract_sentences.to_csv(args.save_sentences_to, index=False,
                                        header=None, sep='\t', encoding='utf-8', mode='a')
        sentences += chunk.shape[0]
        print(f'processed {chunk_id} chunk, {sentences} produced')
        chunk_id += 1
