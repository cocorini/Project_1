pragma solidity 0.6.0;

contract Coin {

    string public name; //코인 이름
    string public symbol; //코인 단위
    uint8 public decimals; //코인 소수점 아래 단위
    uint256 public totalSupply; //코인 총량
    address payable public owner; //소유자주소 설정
    
    mapping (address => int8) public blacklist;
    mapping(address => uint256) private balances; //각 주소의 잔고

    event Transfer(address from, address to, uint256 value); //송금 이벤트 알림
    event Blacklist_Transfer(address from, address to, uint256 value);
    event exchange(address from, uint256 balance); //환전 이벤트 알림
    event trust(address from, uint256 trustvalue); //신뢰도?
    event Blacklisted(address indexed target);
    event RejectedPaymentToBlacklistedAddr(address indexed from, address indexed to, uint256 value);
    event INIT(address user, uint256 value);
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {  // 컨트랙트 생성 될 때 실행되는 함수

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        owner = (msg.sender);
    }

    modifier isowner{
        require (msg.sender == owner); //함수 동작 시, 배포자와 소유자 동일
        _;
    }
    
    //회사잔고를 실제 테스트 코인으로 설정할 수 없을까?
    //회사잔고를 value으로 초기화시켜놓자, 먼저해놓기
    function initial(address user, uint256 value) public{
        balances[user]=value;
        emit INIT(user, value);
    }

    function reveive() payable external {  // 스마트 컨트랙트가 이더를 받을 수 있게 함

        owner.transfer(msg.value);
        emit exchange(msg.sender, balances[msg.sender]); // 송금 보낸 코인(이더)의 값
    }
    
    function readtotalSupply() public view returns(uint256){

        return totalSupply;
    }

    function _transfer(address to, uint256 value) public returns(bool){  // 가스를 소비, 실패 시 에러 발생

        if(balances[msg.sender] >=value && value > 0){  // 해당 주소의 이더 잔액
            balances[msg.sender] -= value;
            balances[to] += value;
            emit Transfer(msg.sender, to, value);
            return true;
        } else {return false;}
    }

    function blacklist_transfer(address to, uint256 value) public{

        require(balances[msg.sender] >= value);
        require(balances[to] + value >= balances[to]);

        if(blacklist[to] == 1)
            emit RejectedPaymentToBlacklistedAddr(msg.sender, to, value);
        else{
            balances[msg.sender] -= value;
            balances[to] += value;
           emit Blacklist_Transfer(msg.sender, to, value);
        }
    }

    function checkbalance() public view returns(uint256){

        return balances[msg.sender];   
    }

    mapping(address => uint256) public trustvalue;   // 주소 입력 시 정수 출력
    mapping(address => uint256) public x1;
    mapping(address => uint256) public x2;
    mapping(address => uint256) public cnt;

    //먼저해놓기
    function setTrustvalue(address user) public{

        trustvalue[user] = 50;
        x1[user] = 0;
        x2[user] = 0;
        cnt[user] = 0;
    }

    function Trustvalue(address user, bool park_result, bool tilt) public isowner returns(uint256) {

        x1[user] = 0;
        x2[user] = 0;

        if (park_result==true) {
            x1[user] += 1;
        }
        else {
            x1[user] -= 1;
        }
        if (tilt==true) {
            x2[user] += 1;
        }
        else {
            x2[user] -= 1;
        }
        // 가중치에 따른 변수 증감
        cnt[user] += 1;
        trustvalue[user] += x1[user]*2+x2[user];  // 신뢰 점수 식: 모두 만족하면 3점씩 up!
        emit trust(msg.sender,trustvalue[user]);
        return trustvalue[user];  // 신뢰점수 반환
    }

    function token(address to, uint256 value) public returns (bool){

        require(value <= balances[msg.sender]);
        require(to != address(0));  // to값에 어떠한 값이라도 들어왔다면 다음으로 넘어감.
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);  // event 발생하고 emit을 해야지 매개변수값이 블록에 저장이 된다.
        return true;        
    }

    //킥보드를 탄 횟수가 15회 이상이고, trustvalue값이 80이상이면 인센티브를 지급.
    function incentive(address user) public {

        if (cnt[user] >= 15 && trustvalue[user] >= 80){
            token(user, 1);
        }  // 신뢰점수 기준으로 인센티브 지급
    }

    //블랙리스트에 주소 추가하는 함수
    function blacklisting(address _addr) isowner public{

        if (cnt[_addr] >= 15 && trustvalue[_addr] <= 20){
            blacklist[_addr] = 1;
            emit Blacklisted(_addr);
        }
    }
}
