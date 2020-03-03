OUTPUT_DIR=/root/DATA/experiments_data/ncbi_ner_train_test
DATA_DIR=/root/DATA/medical_processing_corpora/NCBI/processed_data_ner/train_test
python /root/biobert/biocodes/detok.py --tokens $OUTPUT_DIR/token_test.txt --labels $OUTPUT_DIR/label_test.txt  --save_to $OUTPUT_DIR/predicted_biobert.txt
python /root/data_processing_utils/combine.py --test_labels $DATA_DIR/test_labels.txt --predicted $OUTPUT_DIR/predicted_biobert.txt --save_to $OUTPUT_DIR/predicted_conll.txt
/root/evaluation_scripts/./conlleval < $OUTPUT_DIR/predicted_conll.txt > $OUTPUT_DIR/eval_results.txt
