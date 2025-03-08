Solidity Smart Contract
1. การป้องกันการล็อคเงินใน Contract
การป้องกันไม่ให้เงินถูกล็อคไว้ใน contract สามารถทำได้โดยการใช้การตรวจสอบและเงื่อนไขที่ทำให้เงินถูกถอนออกจาก contract เมื่อถึงเงื่อนไขที่กำหนด เช่น เมื่อเวลาผ่านไปพอสมควร หรือเมื่อตัวเลือกของผู้เล่นได้รับการเปิดเผยเรียบร้อยแล้ว ในกรณีนี้จะมีการป้องกันการล็อคเงินไว้ใน contract ในฟังก์ชัน withdraw และการจัดการกับการถอนเงินหลังจากเกมเสร็จสิ้น โดยมีรายละเอียดดังนี้
ฟังก์ชัน withdraw
function withdraw() public onlyAllowed {
    require(numPlayer == 1 && elapsedMinutes() >= 5, "Cannot withdraw yet");
    require(!hasWithdrawn[msg.sender], "Already withdrawn");
    payable(msg.sender).transfer(reward);
    hasWithdrawn[msg.sender] = true;
    _resetGame();
}
อธิบายแต่ละบรรทัด คือ
require(numPlayer == 1 && elapsedMinutes() >= 5, "Cannot withdraw yet");
ตรวจสอบว่า: ผู้เล่นต้องเหลือแค่ 1 คนในเกม (หมายถึงอีกฝ่ายไม่ได้เล่นหรือถอนเงินไปแล้ว)
เวลาที่ผ่านไปจากการเริ่มเกมต้องมากกว่า 5 นาที (เพื่อให้แน่ใจว่ามีเวลาพอสมควรในการตัดสินใจ)
ถ้าผู้เล่นยังไม่ครบ หรือเวลาไม่ครบ 5 นาที จะไม่สามารถถอนเงินได้ และจะมีข้อความว่า "Cannot withdraw yet"

require(!hasWithdrawn[msg.sender], "Already withdrawn");
ตรวจสอบว่า
ผู้เล่นยังไม่ได้ทำการถอนเงิน ถ้าผู้เล่นถอนเงินไปแล้ว ระบบจะไม่อนุญาตให้ทำการถอนซ้ำ และจะแสดงข้อความว่า "Already withdrawn"

payable(msg.sender).transfer(reward);
หากเงื่อนไขข้างต้นผ่าน ผู้เล่นที่เรียกฟังก์ชันนี้สามารถรับเงินรางวัล (reward) ที่ได้จากเกม โดยการโอน Ether ไปยังที่อยู่ของผู้เล่นที่เรียกฟังก์ชัน

hasWithdrawn[msg.sender] = true;
เมื่อการถอนสำเร็จ จะบันทึกสถานะว่า ผู้เล่นได้ถอนเงินไปแล้ว เพื่อป้องกันไม่ให้ผู้เล่นถอนเงินซ้ำ

_resetGame();
หลังจากการถอนเงินแล้ว จะรีเซ็ตข้อมูลทั้งหมดของเกม (เช่น การคืนค่าตัวแปรต่างๆ เช่น numPlayer, reward, และข้อมูลเกี่ยวกับผู้เล่น) เพื่อเตรียมเกมใหม่

การป้องกันการล็อคเงิน

ฟังก์ชัน withdraw จะป้องกันการล็อคเงินใน contract ด้วยการ
การใช้เวลา: ผู้เล่นจะต้องรอให้เวลาผ่านไปเกิน 5 นาที ก่อนที่จะสามารถถอนเงินได้ ซึ่งทำให้ไม่สามารถมีการล็อคเงินใน contract หากผู้เล่นไม่สามารถถอนออกได้ทันที
การตรวจสอบสถานะการถอน: ถ้าผู้เล่นทำการถอนเงินไปแล้วจะไม่สามารถถอนซ้ำได้ เพื่อป้องกันการดึงเงินออกซ้ำสอง
การรีเซ็ตข้อมูล: หลังจากการถอนเงินและการจ่ายรางวัล ระบบจะรีเซ็ตเกมทั้งหมด ซึ่งทำให้ไม่สามารถเก็บเงินไว้ใน contract ได้หลังจากเกมเสร็จสิ้น
การตั้งเวลาและการตรวจสอบสถานะการถอนจะช่วยให้ระบบไม่เกิดการล็อคเงินใน contract และทำให้เงินสามารถถูกถอนออกจาก contract ได้อย่างปลอดภัยเมื่อเงื่อนไขครบถ้วน



2. การซ่อน Choice และ Commit
ฟังก์ชัน commit
function commit(bytes32 dataHash) public {
    commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
    emit CommitHash(msg.sender, dataHash, commits[msg.sender].blockNumber);
}
การทำงาน:
เมื่อผู้เล่นเรียกฟังก์ชัน commit เขาจะส่งค่า dataHash (ค่าที่เข้ารหัสจากการเลือกของเขา เช่น "rock" หรือ "paper" ในเกม Rock-Paper-Scissors-Lizard-Spock) ไปที่ contract ข้อมูลที่ส่งไปคือ dataHash ที่เป็น hash ที่ได้จากการเข้ารหัสการเลือกของผู้เล่น โดยการใช้ฟังก์ชัน keccak256 ซึ่งเป็นฟังก์ชันเข้ารหัสใน Solidity
Contract จะบันทึกข้อมูลนี้ในตัวแปร commits[msg.sender] ซึ่งเป็นโครงสร้างข้อมูล Commit ที่ประกอบด้วย:

dataHash: ค่าของการเข้ารหัสการเลือก
blockNumber: หมายเลขของบล็อกที่ commit นี้ถูกบันทึก (ใช้เพื่อจำกัดเวลาในการเปิดเผยภายหลัง)
revealed: สถานะว่าเลือกนี้ได้รับการเปิดเผยแล้วหรือยัง (false หมายถึงยังไม่ได้เปิดเผย)
ในที่สุด contract จะ emit event เพื่อให้มีการบันทึกเหตุการณ์นี้ในบล็อกเชน

ฟังก์ชัน reveal
function reveal(bytes32 revealHash) public {
    require(!commits[msg.sender].revealed, "Already revealed");
    require(getHash(revealHash) == commits[msg.sender].commit, "Hash mismatch");
    require(block.number > commits[msg.sender].blockNumber, "Same block reveal not allowed");
    require(block.number <= commits[msg.sender].blockNumber + 250, "Reveal too late");

    commits[msg.sender].revealed = true;
    emit RevealHash(msg.sender, revealHash);
}
การทำงาน:
ก่อนอื่น ฟังก์ชันนี้จะตรวจสอบว่า ผู้เล่นยังไม่เคยเปิดเผยการเลือกของตนมาก่อน (!commits[msg.sender].revealed)
ต่อไปจะมีการตรวจสอบว่า revealHash ที่ส่งมานั้นตรงกับ commit hash ที่ผู้เล่นได้ commit ไว้หรือไม่ (getHash(revealHash) == commits[msg.sender].commit)
ฟังก์ชันจะตรวจสอบว่า การเปิดเผยนั้นเกิดขึ้นหลังจาก commit หรือไม่ โดยตรวจสอบว่า block number ที่เปิดเผยนั้นมากกว่าหมายเลขของบล็อกที่ commit เกิดขึ้น (block.number > commits[msg.sender].blockNumber)
ฟังก์ชันจะตรวจสอบว่า การเปิดเผยนั้นเกิดขึ้นในระยะเวลาที่กำหนด โดยกำหนดให้ผู้เล่นสามารถเปิดเผยได้ภายใน 250 บล็อกหลังจากที่ commit เกิดขึ้น (block.number <= commits[msg.sender].blockNumber + 250)
ถ้าผ่านการตรวจสอบทั้งหมด ฟังก์ชันจะทำการอัปเดตสถานะ revealed เป็น true เพื่อบ่งชี้ว่าได้เปิดเผยการเลือกแล้ว และจะแสดงอีเวนต์ RevealHash เพื่อแจ้งให้ทุกคนทราบว่าได้มีการเปิดเผยข้อมูลแล้ว

ฟังก์ชัน getHash
function getHash(bytes32 data) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(data));
}
การทำงาน:
ฟังก์ชันนี้จะรับข้อมูล data ที่ส่งเข้ามาและทำการเข้ารหัส (hash) โดยใช้ฟังก์ชัน keccak256 ซึ่งเป็นฟังก์ชันการเข้ารหัสที่ใช้ใน Ethereum
การใช้ keccak256 จะช่วยสร้างค่า commit hash หรือ reveal hash ที่ไม่สามารถคาดเดาได้จากการเลือกของผู้เล่น และเป็นการป้องกันไม่ให้ผู้เล่นสามารถโกงได้



3. การจัดการกับความล่าช้าในการเริ่มเกม
ฟังก์ชัน setStartTime และ elapsedMinutes
function setStartTime() internal {
    startTime = block.timestamp;  // บันทึกเวลาเริ่มต้นของเกม
}

function elapsedMinutes() public view returns (uint256) {
    return (block.timestamp - startTime) / 60;  // คำนวณเวลาที่ผ่านไปในหน่วยนาที
}
ฟังก์ชัน setStartTime จะบันทึกเวลาเริ่มต้นของเกมเมื่อผู้เล่นครบสองคน
ฟังก์ชัน elapsedMinutes จะคำนวณระยะเวลาที่ผ่านไปตั้งแต่เวลาเริ่มต้น โดยแปลงเวลาที่เป็นวินาที (จาก block.timestamp) ให้เป็นนาที



4. การ Reveal และตัดสินผู้ชนะ
ฟังก์ชัน revealChoice
function revealChoice(bytes32 revealHash, uint choice) public onlyAllowed {
    require(player_not_played[msg.sender], "Already revealed");
    require(getHash(revealHash) == player_commit[msg.sender], "Invalid reveal");
    require(choice >= 0 && choice <= 4, "Invalid choice");
    player_choice[msg.sender] = choice;
    player_not_played[msg.sender] = false;
    numInput++;

    if (numInput == 2) {
        _checkWinnerAndPay();
    }
}
ฟังก์ชันนี้จะใช้ในการให้ผู้เล่นแต่ละคน เปิดเผยการเลือกของตัวเอง และทำการตรวจสอบว่าข้อมูลที่เปิดเผยถูกต้องหรือไม่ ก่อนที่จะนำมาคำนวณผลลัพธ์ของเกม



5. ฟังก์ชัน _checkWinnerAndPay

function _checkWinnerAndPay() private {
    uint p0Choice = player_choice[players[0]];
    uint p1Choice = player_choice[players[1]];
    address payable account0 = payable(players[0]);
    address payable account1 = payable(players[1]);

    if ((p0Choice + 1) % 5 == p1Choice || (p0Choice + 3) % 5 == p1Choice) {
        account1.transfer(reward);
    } else if ((p1Choice + 1) % 5 == p0Choice || (p1Choice + 3) % 5 == p0Choice) {
        account0.transfer(reward);
    } else {
        account0.transfer(reward / 2);
        account1.transfer(reward / 2);
    }
    _resetGame();
}
ฟังก์ชันนี้จะทำการตัดสินผลของเกมและจ่ายรางวัลให้ผู้ชนะ หรือแบ่งรางวัลในกรณีเสมอ

