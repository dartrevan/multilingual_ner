#!/usr/bin/env bash
WORKING_DIR=/tmp/work_dir
DIS_OUTPUT_DIR=/tmp/dis_outputs
GEN_OUTPUT_DIR=/tmp/gen_outputs
MODEL_DIR=model
DATA_DIR=/data

mkdir $WORKING_DIR
mkdir $DIS_OUTPUT_DIR
mkdir $GEN_OUTPUT_DIR

# split abstracts into sentences
python3 /root/gene_disease_ner/data_processing_utils/split_into_sentences.py --input_file $DATA_DIR/input.csv \
                                                                            --save_sentences_to $WORKING_DIR/test_texts.txt \
                                                                            --save_doc_ids_to $WORKING_DIR/test_doc_ids.txt \
                                                                            --chunksize 100000
printf "O\nB-DISO\nI-DISO\n" > /tmp/work_dir/tagset.txt
cp $MODEL_DIR/dis_model/label2id.pkl $DIS_OUTPUT_DIR
python3 /root/gene_disease_ner/bert_tf/run_ner.py --do_train=False --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/dis_model/model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$DIS_OUTPUT_DIR

cp $MODEL_DIR/gen_model/label2id.pkl $GEN_OUTPUT_DIR
python3 /root/gene_disease_ner/bert_tf/run_ner.py --do_train=False --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/gen_model/model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$GEN_OUTPUT_DIR

python3 /root/gene_disease_ner/data_processing_utils/extract_entities.py --tokens_dis $DIS_OUTPUT_DIR/token_test.txt \
                                                                        --labels_dis $DIS_OUTPUT_DIR/label_test.txt  \
                                                                        --tokens_gen $GEN_OUTPUT_DIR/token_test.txt \
                                                                        --labels_gen $GEN_OUTPUT_DIR/label_test.txt \
                                                                        --input_file $DATA_DIR/input.csv \
                                                                        --doc_ids $WORKING_DIR/test_doc_ids.txt \
                                                                        --save_to $DATA_DIR/output.csv
