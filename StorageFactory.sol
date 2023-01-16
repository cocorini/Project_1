// SPDX-License-Identifier: MIT
// 버전 설정
pragma solidity ^0.6.0;
// SimpleStorage.sol의 모든 코드가 복사됨. 다만, import된 contract를 import된 파일 안에서 실행할 수 없다.
import "./SimpleStorage.sol";
//상속의 개념을 이용, StorageFactory는 SimpleStorage의 모든 기능을 물려받는다.
contract StorageFactory is SimpleStorage{
    //SimpleStorage형 배열 선언
    SimpleStorage[] public simpleStorageArray;
    //simplestoragecontract를 만드는 함수.
    function createSimpleStorageContract() public{
        SimpleStorage SimpleStorage = new SimpleStorage();
        simpleStorageArray.push(SimpleStorage);
    }
    //저장고를 골라 그 저장고에 양의 정수 하나를 입력하는 역할
    //즉, 저장고의 인덱스와 어떤 값을 넣을지를 정하는 양의 정수를 입력해놔야한다.
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public{
        SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(_simpleStorageNumber);
    }
    //저장된 양의 정수를 출력하는 역할
    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256) {
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
    }
}
