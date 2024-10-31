global class TS4_IS_CheckBusinessHoursChatBot {
    global static Boolean checkBusinessHoursById(String businessHoursId)
    {
        System.debug('Método checkBusinessHoursById iniciado con ID: ' + businessHoursId);
        Boolean isWithin = false;
        if (businessHoursId != null)
        {
            Datetime now = System.now();
            System.debug('Hora actual: ' + now);
            System.debug('Zona horaria del contexto: ' + UserInfo.getTimeZone().getID());
            
            BusinessHours bh = [SELECT Id, Name, TimeZoneSidKey, 
                                       MondayStartTime, MondayEndTime,
                                       TuesdayStartTime, TuesdayEndTime,
                                       WednesdayStartTime, WednesdayEndTime,
                                       ThursdayStartTime, ThursdayEndTime,
                                       FridayStartTime, FridayEndTime,
                                       SaturdayStartTime, SaturdayEndTime,
                                       SundayStartTime, SundayEndTime
                                FROM BusinessHours 
                                WHERE Id = :businessHoursId];
            System.debug('BusinessHours encontrado: ' + bh);
            System.debug('Zona horaria de BusinessHours: ' + bh.TimeZoneSidKey);
            
            isWithin = BusinessHours.isWithin(businessHoursId, now);
            System.debug('¿Está dentro del horario comercial? ' + isWithin);
            
            // Comprobación manual del horario
            String[] daysOfWeek = new String[]{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
            Integer dayIndex = Math.mod(now.dayGmt() - 1 + 7, 7);  // Adjusting for GMT
            String todayDay = daysOfWeek[dayIndex];
            
            Time startTime = (Time)bh.get(todayDay + 'StartTime');
            Time endTime = (Time)bh.get(todayDay + 'EndTime');
            Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);
            
            Boolean manualCheck = false;
            if (startTime != null && endTime != null) {
                manualCheck = (currentTime >= startTime && currentTime <= endTime);
            }
            
            System.debug('Día actual: ' + todayDay);
            System.debug('Horario del día: ' + startTime + ' - ' + endTime);
            System.debug('Hora actual: ' + currentTime);
            System.debug('Comprobación manual: ' + manualCheck);
            
            if (isWithin != manualCheck) {
                System.debug('¡Advertencia! La comprobación automática y manual no coinciden.');
            }
            
            // Usar la comprobación manual en lugar de isWithin
            isWithin = manualCheck;
        }
        else
        {
            System.debug('businessHoursId es null');
        }
        
        System.debug('Resultado final de isWithin: ' + isWithin);
        return isWithin;
    }
    
    @InvocableMethod(label='Check Now is within Business Hours')
    global static List<Boolean> checkBusinessHoursByName()
    {

        List<Boolean> results = new List<Boolean>();
        
            List<BusinessHours> businessHours = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic' AND IsActive = true];
            if (businessHours.size() == 1) {
                results.add(TS4_IS_CheckBusinessHoursChatBot.checkBusinessHoursById(businessHours[0].Id));
            }
            else
            {
                results.add(false);
            }
        System.debug('results BH'+results);
        return results;
    }

}