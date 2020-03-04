#!/usr/bin/env bash
WORKING_DIR=/tmp/work_dir
DIS_OUTPUT_DIR=/tmp/dis_outputs
GEN_OUTPUT_DIR=/tmp/gen_outputs
MODEL_DIR=/dis_model
DATA_DIR=/data

# split abstracts into sentences
python /root/gene_disease_ner/data_processing_utils/split_into_sentences.py --input_file $DATA_DIR/input.csv \
                                                                            --save_sentences_to $WORKING_DIR/test_texts.txt \
                                                                            --save_doc_ids_to $WORKING_DIR/test_doc_ids.txt \
                                                                            --chunksize 100000

python /root/gene_disease_ner/bert_tf/run_ner.py --do_train=Flase --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/dis_model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$DIS_OUTPUT_DIR

python /root/gene_disease_ner/bert_tf/run_ner.py --do_train=Flase --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/gen_model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$GEN_OUTPUT_DIR

python /root/gene_disease_ner/data_processing_utils/extract_entities.py --tokens_dis $DIS_OUTPUT_DIR/token_test.txt \
                                                                        --labels_dis $DIS_OUTPUT_DIR/label_test.txt  \
                                                                        --tokens_gen $GEN_OUTPUT_DIR/toke_test.txt \
                                                                        --labels_gen $GEN_OUTPUT_DIR/label_test.txt \
                                                                        --input_file $DATA_DIR/input.csv \
                                                                        --doc_ids $WORKING_DIR/test_doc_ids.txt \
                                                                        --save_to $DATA_DIR/output.csv
