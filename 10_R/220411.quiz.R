# 하나의 점수를 입력받아 80점이상이면 합격 아니면 불합격으로 출력
a = readline("점수입력:")
a = as.numeric(a)
rst = ifelse(a>80, "합격", "불합격")
print(rst)