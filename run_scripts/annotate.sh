#!/usr/bin/env bash
WORKING_DIR=/tmp/work_dir
DIS_OUTPUT_DIR=/tmp/dis_outputs
GEN_OUTPUT_DIR=/tmp/gen_outputs
MODEL_DIR=model
DATA_DIR=/data

mkdir $WORKING_DIR
mkdir $OUTPUT_DIR

# split abstracts into sentences
python3 /root/gene_disease_ner/data_processing_utils/split_into_sentences.py --input_file $DATA_DIR/input.csv \
                                                                            --save_sentences_to $WORKING_DIR/test_texts.txt \
                                                                            --save_doc_ids_to $WORKING_DIR/test_doc_ids.txt
# cp tagset
printf "O\nB-DISO\nI-DISO\n" > /tmp/work_dir/tagset.txt
cp $MODEL_DIR/dis_model/label2id.pkl $DIS_OUTPUT_DIR
python3 /root/gene_disease_ner/bert_tf/run_ner.py --do_train=False --do_predict=True --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$OUTPUT_DIR
