#!/usr/bin/env bash
WORKING_DIR=/tmp/work_dir
OUTPUT_DIR=/tmp/outputs
MODEL_DIR=model
DATA_DIR=/data

mkdir $WORKING_DIR
mkdir $OUTPUT_DIR

# split abstracts into sentences
python3 /root/multilingual_ner/data_processing_utils/split_into_sentences.py --input_file $DATA_DIR/input.txt \
                                                                            --save_sentences_to $WORKING_DIR/test_texts.txt \
                                                                            --save_doc_ids_to $WORKING_DIR/test_doc_ids.txt
# cp tagset
cp $MODEL_DIR/tagset.txt  $WORKING_DIR/
cp $MODEL_DIR/label2id.pkl $OUTPUT_DIR/
python3 /root/multilingual_ner/bert_tf/run_ner.py --do_train=False --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$OUTPUT_DIR

python3 /root/multilingual_ner/data_processing_utils/detok.py --tokens $OUTPUT_DIR/token_test.txt --labels $OUTPUT_DIR/label_test.txt --save_to $OUTPUT_DIR/predicted_biobert.txt

python3 /root/multilingual_ner/data_processing_utils/conll2json.py --conll_file $OUTPUT_DIR/predicted_biobert.txt \
                                                                   --save_to $DATA_DIR/output.txt \
                                                                   --document_ids $WORKING_DIR/test_doc_ids.txt
