clear
%% 가져오기 옵션을 설정하고 데이터 가져오기
opts = delimitedTextImportOptions("NumVariables", 4);

% 범위 및 구분 기호 지정
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% 열 이름과 유형 지정
opts.VariableNames = ["u","v","u_old","v_old"];
opts.SelectedVariableNames = ["u","v","u_old","v_old"];
opts.VariableTypes = ["double","double","double","double"];

% 파일 수준 속성 지정
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 데이터 가져오기
tbl = readtable("D:\Dropbox\Study\UC Davis\Writings\Labor Shortage\210718\직종별사업체노동력조사 2021_지역\matlab\beveridgegraph.csv", opts);

%% 출력 유형으로 변환
u= tbl.u;
v= tbl.v;
u_old= tbl.u_old;
v_old= tbl.v_old;

%% 임시 변수 지우기
clear opts tbl


k=.36121565
a(1)=2.116624
a(20)=1.717195
theta=v./u
gamma(1)=(u(1)*a(1)*theta(1)^k)/(1-u(1))
gamma(20)=(u(20)*a(20)*theta(20)^k)/(1-u(20))

%% Graph: final1.eps
syms y x
hold on
pointsize = 10;
scatter(u_old, v_old, pointsize, 'k', 'filled');
line(u_old,v_old,'color','k','linewidth',1), axis([0.0 0.03 0 0.02])
y=0.472651037*x
fplot(x,y,[0,0.03],'-k','LineWidth',1)
y=0.345118601*x
fplot(x,y,[0,0.03],'-k','LineWidth',1)
y=0.779746661*x
fplot(x,y,[0,0.03],'-k','LineWidth',1)
y=((gamma(1)*(1-x))/(a(1)*x^(1-k)))^(1/k)
fplot(x,y,[0.001,0.06],'-k','LineWidth',1)
y=((gamma(20)*(1-x))/(a(20)*x^(1-k)))^(1/k)
fplot(x,y,[0.001,0.06],'-k','LineWidth',1)
scatter(u,v,'filled','r')
line(u,v,'color','r','linewidth',1)
hold off


