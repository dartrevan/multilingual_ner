BIOBERT_DIR=/root/DATA/pretrained_models/biobert_v1.1_pubmed
DATA_DIR=/root/DATA/medical_processing_corpora/NCBI/processed_data_ner/train_test
OUTPUT_DIR=/root/DATA/experiments_data/ncbi_ner_train_test
mkdir $OUTPUT_DIR
CUDA_VISIBLE_DEVICES=6 python /root/biobert/run_ner.py --do_train=True --do_predict=True --vocab_file=$BIOBERT_DIR/vocab.txt --bert_config_file=$BIOBERT_DIR/bert_config.json \
    --init_checkpoint=$BIOBERT_DIR/model.ckpt-1000000 \
    --num_train_epochs 70.0  --data_dir=$DATA_DIR  \
    --output_dir=$OUTPUT_DIR  \
    --save_checkpoints_steps 5000 &

BIOBERT_DIR=/root/DATA/pretrained_models/biobert_v1.1_pubmed
DATA_DIR=/root/DATA/medical_processing_corpora/NCBI/processed_data_ner/train_test_combined
OUTPUT_DIR=/root/DATA/experiments_data/ncbi_ner_train_test_combined
mkdir $OUTPUT_DIR
CUDA_VISIBLE_DEVICES=7 python /root/biobert/run_ner.py --do_train=True --do_predict=True --vocab_file=$BIOBERT_DIR/vocab.txt --bert_config_file=$BIOBERT_DIR/bert_config.json \
    --init_checkpoint=$BIOBERT_DIR/model.ckpt-1000000 \
    --num_train_epochs 70.0  --data_dir=$DATA_DIR  \
    --output_dir=$OUTPUT_DIR  \
    --save_checkpoints_steps 5000
