#!/usr/bin/env bash
WORKING_DIR=/tmp/work_dir
FINETUNED_MODEL_DIR=/tmp/finetuned_model
MODEL_DIR=model
DATA_DIR=/data

mkdir $FINETUNED_MODEL_DIR
mkdir $WORKING_DIR

python3 /root/multilingual_ner/data_processing_utils/conll2plain.py --input $DATA_DIR/train.csv --save_texts_to $WORKING_DIR/train_texts.txt --save_labels_to $WORKING_DIR/train_labels.txt
cp $MODEL_DIR/tagset.txt  $WORKING_DIR/

python3 /root/multilingual_ner/bert_tf/run_ner.py --do_train=True --do_predict=False --vocab_file=$MODEL_DIR/vocab.txt \
                                                 --bert_config_file=$MODEL_DIR/bert_config.json \
                                                 --init_checkpoint=$MODEL_DIR/model.ckpt \
                                                 --data_dir=$WORKING_DIR  \
                                                 --output_dir=$FINETUNED_MODEL_DIR \
                                                 --num_train_epochs=30
